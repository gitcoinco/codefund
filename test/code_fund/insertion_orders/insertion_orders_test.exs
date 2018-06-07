defmodule CodeFund.InsertionOrdersTest do
  use CodeFund.DataCase
  alias CodeFund.InsertionOrders
  alias CodeFund.Schema.InsertionOrder
  import CodeFund.Factory

  describe "insertion_orders" do
    test "paginate_insertion_orders/1 returns paginated results" do
      insert_list(25, :insertion_order)
      {:ok, results} = InsertionOrders.paginate_insertion_orders(nil)
      assert results.distance == 5
      assert results.page_number == 1
      assert results.page_size == 15
      assert results.sort_direction == "desc"
      assert results.sort_field == "inserted_at"
      assert results.total_entries == 25
      assert results.total_pages == 2
      assert length(results.insertion_orders) == 15
    end

    test "get_insertion_order!/1 returns the insertion_order with given id" do
      insertion_order = insert(:insertion_order)
      assert InsertionOrders.get_insertion_order!(insertion_order.id).id == insertion_order.id
    end

    test "create_insertion_order/1 with valid data creates a insertion_order" do
      assert {:ok, %InsertionOrder{} = insertion_order} =
               InsertionOrders.create_insertion_order(
                 string_params_with_assocs(
                   :insertion_order,
                   impression_count: 20,
                   billing_cycle: "2018-01-01"
                 )
               )

      assert insertion_order.impression_count == 20
      assert insertion_order.billing_cycle == ~N[2018-01-01 00:00:00]
    end

    test "create_insertion_order/1 with invalid data returns error changeset" do
      invalid_attrs =
        string_params_with_assocs(
          :insertion_order,
          impression_count: nil,
          billing_cycle: "2018-01-01"
        )

      assert {:error, %Ecto.Changeset{}} = InsertionOrders.create_insertion_order(invalid_attrs)
    end

    test "change_insertion_order/1 returns changeset" do
      assert %Ecto.Changeset{} = InsertionOrders.change_insertion_order(%InsertionOrder{})
    end

    test "update_insertion_order/2 with valid data updates the insertion_order" do
      insertion_order = insert(:insertion_order)

      assert {:ok, insertion_order} =
               InsertionOrders.update_insertion_order(insertion_order, %{
                 "impression_count" => 100,
                 "billing_cycle" => "2018-01-01"
               })

      assert %InsertionOrder{} = insertion_order
      assert insertion_order.impression_count == 100
    end

    test "update_insertion_order/2 with invalid data returns error changeset" do
      insertion_order = insert(:insertion_order)

      assert {:error, %Ecto.Changeset{}} =
               InsertionOrders.update_insertion_order(insertion_order, %{impression_count: nil})

      assert insertion_order.impression_count ==
               InsertionOrders.get_insertion_order!(insertion_order.id).impression_count
    end

    test "delete_insertion_order/1 deletes the insertion_order" do
      insertion_order = insert(:insertion_order)
      assert {:ok, %InsertionOrder{}} = InsertionOrders.delete_insertion_order(insertion_order)

      assert_raise Ecto.NoResultsError, fn ->
        InsertionOrders.get_insertion_order!(insertion_order.id)
      end
    end
  end
end
