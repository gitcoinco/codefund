defmodule CodeFund.CreativesTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  alias CodeFund.Creatives
  alias CodeFund.Schema.Creative

  setup do
    creative = insert(:creative)
    {:ok, %{creative: creative}}
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

    test "delete_creative/1 deletes the creative" do
      creative = insert(:creative)
      assert {:ok, %Creative{}} = Creatives.delete_creative(creative)
      assert_raise Ecto.NoResultsError, fn -> Creatives.get_creative!(creative.id) end
    end

    test "change_creative/1 returns a creative changeset", %{creative: creative} do
      assert %Ecto.Changeset{} = Creatives.change_creative(creative)
    end
  end
end
