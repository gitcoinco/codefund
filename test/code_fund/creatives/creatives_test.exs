defmodule CodeFund.CreativesTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  alias CodeFund.Creatives
  alias CodeFund.Schema.Creative

  setup do
    {:ok, %{creative: insert(:creative)}}
  end

  describe "creatives" do
    test "paginate_creatives/1 returns paginated results" do
      user = insert(:user)
      insert_list(25, :creative, user: user)
      insert_list(25, :creative)

      {:ok, results} = Creatives.paginate_creatives(user)
      assert results.distance == 5
      assert results.page_number == 1
      assert results.page_size == 15
      assert results.sort_direction == "desc"
      assert results.sort_field == "inserted_at"
      assert results.total_entries == 25
      assert results.total_pages == 2
      assert length(results.creatives) == 15
    end

    test "get_by_property_filters" do
      creative = insert(:creative)
      audience = insert(:audience, %{programming_languages: ["Ruby", "C"]})

      insert(:audience, %{programming_languages: ["Java", "Rust"]})

      campaign =
        insert(
          :campaign,
          status: 2,
          bid_amount: Decimal.new(1),
          budget_daily_amount: Decimal.new(1),
          budget_monthly_amount: Decimal.new(1),
          budget_total_amount: Decimal.new(1),
          creative: creative,
          audience: audience
        )

      insert(
        :campaign,
        status: 2,
        bid_amount: Decimal.new(0),
        budget_daily_amount: Decimal.new(0),
        budget_monthly_amount: Decimal.new(0),
        budget_total_amount: Decimal.new(0),
        creative: creative,
        audience: audience
      )

      insert(
        :campaign,
        status: 2,
        bid_amount: Decimal.new(1),
        budget_daily_amount: Decimal.new(1),
        budget_monthly_amount: Decimal.new(1),
        budget_total_amount: Decimal.new(1),
        creative: creative,
        audience: insert(:audience, %{programming_languages: ["Java", "Rust"]})
      )

      insert(
        :campaign,
        status: 1,
        bid_amount: Decimal.new(1),
        budget_daily_amount: Decimal.new(1),
        budget_monthly_amount: Decimal.new(1),
        budget_total_amount: Decimal.new(1),
        creative: creative,
        audience: audience
      )

      loaded_creative =
        Creatives.get_by_property_filters(programming_languages: ["C"]) |> CodeFund.Repo.one()

      assert loaded_creative == %{
               "body" => "This is a Test Creative",
               "campaign_id" => campaign.id,
               "image_url" => "http://example.com/some.png",
               "headline" => "Creative Headline"
             }
    end

    test "by_user/1 returns creatives by user" do
      user = insert(:user)
      insert_list(25, :creative, user: user)
      insert_list(25, :creative)

      assert Creatives.by_user(user) |> length == 25
    end

    test "list_creatives/0 returns all creatives", %{creative: creative} do
      creatives = Creatives.list_creatives()
      assert creatives |> Enum.count() == 1
      assert creatives |> List.first() |> Map.get(:id) == creative.id
      assert creatives |> List.first() |> Map.get(:__struct__) == Creative
    end

    test "get_creative!/1 returns the creative with given id", %{creative: creative} do
      insert(:creative)
      assert Creatives.get_creative!(creative.id) == creative
    end

    test "create_creative/1 with valid data creates a creative" do
      assert {:ok, %Creative{} = creative} =
               Creatives.create_creative(params_with_assocs(:creative))

      assert creative.image_url == "http://example.com/some.png"
      assert creative.body == "This is a Test Creative"
      assert creative.headline == "Creative Headline"
    end

    test "create_creative/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               params_with_assocs(:creative) |> Map.delete(:body) |> Creatives.create_creative()
    end

    test "update_creative/2 with valid data updates the creative", %{creative: creative} do
      assert {:ok, creative} = Creatives.update_creative(creative, %{body: "New Body"})
      assert %Creative{} = creative
      assert creative.body == "New Body"
    end

    test "update_creative/2 with invalid data returns error changeset", %{creative: creative} do
      assert {:error, %Ecto.Changeset{}} = Creatives.update_creative(creative, %{body: ""})
      assert Creatives.get_creative!(creative.id).body == "This is a Test Creative"
    end

    test "delete_creative/1 deletes the creative", %{creative: creative} do
      assert {:ok, %Creative{}} = Creatives.delete_creative(creative)
      assert_raise Ecto.NoResultsError, fn -> Creatives.get_creative!(creative.id) end
    end

    test "change_creative/1 returns a creative changeset", %{creative: creative} do
      assert %Ecto.Changeset{} = Creatives.change_creative(creative)
    end
  end
end
