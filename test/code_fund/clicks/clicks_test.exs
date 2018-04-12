defmodule CodeFund.ClicksTest do
  use CodeFund.DataCase
  import CodeFund.Sigils
  alias CodeFund.Clicks
  alias CodeFund.Schema.Click
  import CodeFund.Factory

  describe "clicks" do
    @valid_attrs %{ip: "121.12.1.31", revenue_amount: ~n(2.00), distribution_amount: ~n(1.20)}
    @update_attrs %{ip: "10.12.1.31", revenue_amount: ~n(0.00)}
    @invalid_attrs %{ip: nil, revenue_amount: ~n(-1.00), distribution_amount: ~n(-1.00)}

    test "paginate_clicks/1 returns paginated results" do
      insert_list(25, :click)
      {:ok, results} = Clicks.paginate_clicks()
      assert results.distance == 5
      assert results.page_number == 1
      assert results.page_size == 15
      assert results.sort_direction == "desc"
      assert results.sort_field == "inserted_at"
      assert results.total_entries == 25
      assert results.total_pages == 2
      assert length(results.clicks) == 15
    end

    test "list_clicks/0 returns all clicks" do
      click = insert(:click)
      subject = Clicks.list_clicks() |> Enum.at(0)
      assert subject.id == click.id
    end

    test "get_click!/1 returns the click with given id" do
      click = insert(:click)
      assert Clicks.get_click!(click.id).id == click.id
    end

    test "create_click/1 with valid data creates a click" do
      property = insert(:property)

      assert {:ok, %Click{} = click} =
               Clicks.create_click(Map.merge(@valid_attrs, %{property_id: property.id}))

      assert click.property_id == property.id
      assert click.ip == @valid_attrs[:ip]
      assert click.revenue_amount == ~n(2.00)
      assert click.distribution_amount == ~n(1.20)
    end

    test "create_click/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clicks.create_click(@invalid_attrs)
    end

    test "update_click/2 with valid data updates the click" do
      click = insert(:click, @valid_attrs)
      assert {:ok, click} = Clicks.update_click(click, @update_attrs)
      assert %Click{} = click
      assert click.ip == @update_attrs[:ip]
      assert click.revenue_amount == ~n(0.00)
    end

    test "update_click/2 with invalid data returns error changeset" do
      click = insert(:click, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Clicks.update_click(click, @invalid_attrs)
      assert click.ip == Clicks.get_click!(click.id).ip
    end

    test "delete_click/1 deletes the click" do
      click = insert(:click)
      assert {:ok, %Click{}} = Clicks.delete_click(click)
      assert_raise Ecto.NoResultsError, fn -> Clicks.get_click!(click.id) end
    end

    test "change_click/1 returns a click changeset" do
      click = insert(:click)
      assert %Ecto.Changeset{} = Clicks.change_click(click)
    end

    test "set_status/2 sets the status of the click" do
      click = insert(:click, %{status: Click.statuses()[:pending]})
      assert click.status == Click.statuses()[:pending]
      assert {:ok, %Click{} = click} = Clicks.set_status(click, :fraud)
      assert click.status == Click.statuses()[:fraud]
      assert click.is_fraud
      assert {:ok, %Click{} = click} = Clicks.set_status(click, :redirected)
      assert click.status == Click.statuses()[:redirected]
      refute click.is_fraud
    end

    test "is_duplicate?/2 with no duplicate" do
      sponsorship = insert(:sponsorship)
      days_ago = Timex.shift(Timex.now(), days: -10)
      insert(:click, %{ip: "1.2.3.4", inserted_at: days_ago, sponsorship: sponsorship})
      refute Clicks.is_duplicate?(sponsorship.id, "1.2.3.4")
    end

    test "is_duplicate?/2 with duplicate" do
      sponsorship = insert(:sponsorship)
      days_ago = Timex.shift(Timex.now(), days: -3)
      insert(:click, %{ip: "1.2.3.4", inserted_at: days_ago, sponsorship: sponsorship, status: 1})
      assert Clicks.is_duplicate?(sponsorship.id, "1.2.3.4")
    end
  end
end
