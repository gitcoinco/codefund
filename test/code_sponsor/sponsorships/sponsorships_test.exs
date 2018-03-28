defmodule CodeFund.SponsorshipsTest do
  use CodeFund.DataCase
  alias CodeFund.Properties
  alias CodeFund.Schema.Property
  alias CodeFund.Sponsorships
  alias CodeFund.Schema.Sponsorship
  import CodeFund.Factory

  describe "sponsorships" do
    @valid_attrs %{bid_amount: 1.50, redirect_url: "https://gitcoin.co"}
    @update_attrs %{bid_amount: 2.25, redirect_url: "https://codesponsor.io"}
    @invalid_attrs %{bid_amount: nil, redirect_url: "consensys.net"}

    test "paginate_sponsorships/1 returns paginated results" do
      insert_list(25, :sponsorship)
      {:ok, results} = Sponsorships.paginate_sponsorships()
      assert results.distance == 5
      assert results.page_number == 1
      assert results.page_size == 15
      assert results.sort_direction == "desc"
      assert results.sort_field == "inserted_at"
      assert results.total_entries == 25
      assert results.total_pages == 2
      assert length(results.sponsorships) == 15
    end

    test "list_sponsorships/0 returns all sponsorships" do
      sponsorship = insert(:sponsorship)
      subject = Sponsorships.list_sponsorships() |> Enum.at(0)
      assert subject.id == sponsorship.id
    end

    test "get_sponsorship!/1 returns the sponsorship with given id" do
      sponsorship = insert(:sponsorship)
      assert Sponsorships.get_sponsorship!(sponsorship.id).id == sponsorship.id
    end

    test "get_sponsorship_for_property/1 with linked sponsorship returns sponsorship" do
      property = insert(:property)
      sponsorship = insert(:sponsorship, property: property)
      Property.changeset(property, %{sponsorship_id: sponsorship.id}) |> Repo.update()
      property = Properties.get_property!(property.id)

      sponsorship = Sponsorships.get_sponsorship_for_property(property)
      assert sponsorship.id == property.sponsorship_id
    end

    test "get_sponsorship_for_property/1 with non-linked sponsorship returns sponsorship" do
      property = insert(:property)

      insert(:sponsorship, property: property)

      property = Properties.get_property!(property.id)
      sponsorship = Sponsorships.get_sponsorship_for_property(property)

      # refresh
      property = Properties.get_property!(property.id)

      assert sponsorship.id == property.sponsorship_id
    end

    test "create_sponsorship/1 with valid data creates a sponsorship" do
      assert {:ok, %Sponsorship{} = sponsorship} = Sponsorships.create_sponsorship(@valid_attrs)
      assert sponsorship.bid_amount == Decimal.new(1.50)
    end

    test "create_sponsorship/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sponsorships.create_sponsorship(@invalid_attrs)
    end

    test "update_sponsorship/2 with valid data updates the sponsorship" do
      sponsorship = insert(:sponsorship, bid_amount: Decimal.new(1))
      assert {:ok, sponsorship} = Sponsorships.update_sponsorship(sponsorship, @update_attrs)
      sponsorship = Sponsorships.get_sponsorship!(sponsorship.id) # reload
      assert %Sponsorship{} = sponsorship
      assert sponsorship.bid_amount == Decimal.new(2.25)
    end

    test "update_sponsorship/2 with invalid data returns error changeset" do
      sponsorship = insert(:sponsorship)

      assert {:error, %Ecto.Changeset{}} =
               Sponsorships.update_sponsorship(sponsorship, @invalid_attrs)

      assert Decimal.equal?(sponsorship.bid_amount, Sponsorships.get_sponsorship!(sponsorship.id).bid_amount)
    end

    test "delete_sponsorship/1 deletes the sponsorship" do
      property = insert(:property)
      sponsorship = insert(:sponsorship, property: property)
      Property.changeset(property, %{sponsorship_id: sponsorship.id}) |> Repo.update()

      assert {:ok, %Sponsorship{}} = Sponsorships.delete_sponsorship(sponsorship)

      property = Properties.get_property!(property.id)

      assert property.sponsorship_id == nil
      assert_raise Ecto.NoResultsError, fn -> Sponsorships.get_sponsorship!(sponsorship.id) end
    end

    test "change_sponsorship/1 returns a sponsorship changeset" do
      sponsorship = insert(:sponsorship)
      assert %Ecto.Changeset{} = Sponsorships.change_sponsorship(sponsorship)
    end
  end
end
