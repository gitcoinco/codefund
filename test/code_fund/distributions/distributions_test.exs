defmodule CodeFund.DistributionsTest do
  use CodeFund.DataCase
  alias CodeFund.Distributions
  alias CodeFund.Schema.Distribution
  import CodeFund.Factory

  describe "distributions" do
    @valid_attrs %{
      amount: "5.00",
      click_range_start: "2018-01-01 00:00:00",
      click_range_end: "2018-01-03 00:00:00",
      currency: "USD"
    }
    @invalid_attrs %{
      click_range_start: "2018-01-01 00:00:00",
      click_range_end: "2018-01-03 00:00:00",
      currency: "USD"
    }

    test "paginate_distributions/1 returns paginated results" do
      insert_list(25, :distribution, @valid_attrs)
      {:ok, results} = Distributions.paginate_distributions(nil)
      assert results.distance == 5
      assert results.page_number == 1
      assert results.page_size == 15
      assert results.sort_direction == "desc"
      assert results.sort_field == "inserted_at"
      assert results.total_entries == 25
      assert results.total_pages == 2
      assert length(results.distributions) == 15
    end

    test "get_distribution!/1 returns the distribution with given id" do
      distribution = insert(:distribution, @valid_attrs)
      assert Distributions.get_distribution!(distribution.id).id == distribution.id
    end

    test "create_distribution/1 with valid data creates a distribution" do
      assert {:ok, %Distribution{} = distribution} =
               Distributions.create_distribution(
                 string_params_with_assocs(
                   :distribution,
                   amount: "5.00",
                   click_range_end: "2018-01-03"
                 )
               )

      assert distribution.amount == Decimal.new("5.00")
      assert distribution.currency == "USD"
      assert distribution.click_range_start == ~N[2018-01-01 00:00:00]
      assert distribution.click_range_end == ~N[2018-01-03 00:00:00]
    end

    test "create_distribution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Distributions.create_distribution(@invalid_attrs)
    end
  end
end
