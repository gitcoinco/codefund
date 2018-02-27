defmodule CodeSponsor.SponsorshipsTest do
  use CodeSponsor.DataCase

  alias CodeSponsor.Sponsorships

  describe "sponsorships" do
    alias CodeSponsor.Sponsorships.Sponsorship

    @valid_attrs %{bid_amount_cents: 42}
    @update_attrs %{bid_amount_cents: 43}
    @invalid_attrs %{bid_amount_cents: nil}

    def sponsorship_fixture(attrs \\ %{}) do
      {:ok, sponsorship} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sponsorships.create_sponsorship()

      sponsorship
    end

    test "list_sponsorships/0 returns all sponsorships" do
      sponsorship = sponsorship_fixture()
      assert Sponsorships.list_sponsorships() == [sponsorship]
    end

    test "get_sponsorship!/1 returns the sponsorship with given id" do
      sponsorship = sponsorship_fixture()
      assert Sponsorships.get_sponsorship!(sponsorship.id) == sponsorship
    end

    test "create_sponsorship/1 with valid data creates a sponsorship" do
      assert {:ok, %Sponsorship{} = sponsorship} = Sponsorships.create_sponsorship(@valid_attrs)
      assert sponsorship.bid_amount_cents == 42
    end

    test "create_sponsorship/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sponsorships.create_sponsorship(@invalid_attrs)
    end

    test "update_sponsorship/2 with valid data updates the sponsorship" do
      sponsorship = sponsorship_fixture()
      assert {:ok, sponsorship} = Sponsorships.update_sponsorship(sponsorship, @update_attrs)
      assert %Sponsorship{} = sponsorship
      assert sponsorship.bid_amount_cents == 43
    end

    test "update_sponsorship/2 with invalid data returns error changeset" do
      sponsorship = sponsorship_fixture()
      assert {:error, %Ecto.Changeset{}} = Sponsorships.update_sponsorship(sponsorship, @invalid_attrs)
      assert sponsorship == Sponsorships.get_sponsorship!(sponsorship.id)
    end

    test "delete_sponsorship/1 deletes the sponsorship" do
      sponsorship = sponsorship_fixture()
      assert {:ok, %Sponsorship{}} = Sponsorships.delete_sponsorship(sponsorship)
      assert_raise Ecto.NoResultsError, fn -> Sponsorships.get_sponsorship!(sponsorship.id) end
    end

    test "change_sponsorship/1 returns a sponsorship changeset" do
      sponsorship = sponsorship_fixture()
      assert %Ecto.Changeset{} = Sponsorships.change_sponsorship(sponsorship)
    end
  end
end
