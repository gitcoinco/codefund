defmodule CodeFund.ImpressionsTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  alias CodeFund.Impressions
  import CodeFund.Factory

  setup do
    impression = insert(:impression)
    property = insert(:property)
    {:ok, %{impression: impression, property: property}}
  end

  describe "impressions" do
    alias CodeFund.Schema.Impression

    @valid_attrs %{
      browser: "some browser",
      city: "some city",
      country: "some country",
      device_type: "some device_type",
      ip: "some ip",
      latitude: "120.5",
      longitude: "120.5",
      os: "some os",
      postal_code: "some postal_code",
      region: "some region"
    }
    @update_attrs %{
      browser: "some updated browser",
      city: "some updated city",
      country: "some updated country",
      device_type: "some updated device_type",
      ip: "some updated ip",
      latitude: "456.7",
      longitude: "456.7",
      os: "some updated os",
      postal_code: "some updated postal_code",
      region: "some updated region"
    }
    @invalid_attrs %{
      browser: nil,
      city: nil,
      country: nil,
      device_type: nil,
      ip: nil,
      latitude: nil,
      longitude: nil,
      os: nil,
      postal_code: nil,
      region: nil
    }

    test "list_impressions/0 returns all impressions", %{impression: impression} do
      [loaded_impression] = Impressions.list_impressions()
      assert loaded_impression.__struct__ == CodeFund.Schema.Impression
      assert loaded_impression.id == impression.id
    end

    test "get_impression!/1 returns the impression with given id", %{impression: impression} do
      loaded_impression = Impressions.get_impression!(impression.id)
      assert loaded_impression.__struct__ == CodeFund.Schema.Impression
      assert loaded_impression.id == impression.id
    end

    test "create_impression/1 with valid data creates a impression", %{property: property} do
      valid_attrs = @valid_attrs |> Map.merge(%{property_id: property.id})
      {:ok, %Impression{} = impression} = Impressions.create_impression(valid_attrs)
      assert impression.browser == "some browser"
      assert impression.city == "some city"
      assert impression.country == "some country"
      assert impression.device_type == "some device_type"
      assert impression.ip == "some ip"
      assert impression.latitude == Decimal.new("120.5")
      assert impression.longitude == Decimal.new("120.5")
      assert impression.os == "some os"
      assert impression.postal_code == "some postal_code"
      assert impression.region == "some region"
    end

    test "create_impression/1 with invalid data returns error changeset" do
      {:error, %Ecto.Changeset{errors: errors} = changeset} =
        Impressions.create_impression(@invalid_attrs)

      assert errors == [
               property_id: {"can't be blank", [validation: :required]},
               ip: {"can't be blank", [validation: :required]}
             ]

      assert changeset.valid? == false
    end

    test "create_from_sponsorship/1 merges attributes of a sponsorship before saving", %{
      property: property
    } do
      sponsorship = insert(:sponsorship)
      valid_attrs = @valid_attrs |> Map.put(:property_id, property.id)

      {:ok, impression} = Impressions.create_from_sponsorship(valid_attrs, sponsorship)
      reloaded_impression = CodeFund.Repo.get!(CodeFund.Schema.Impression, impression.id)

      assert impression.campaign_id == reloaded_impression.campaign_id
      assert impression.campaign_id == sponsorship.campaign_id

      assert impression.sponsorship_id == reloaded_impression.sponsorship_id
      assert impression.sponsorship_id == sponsorship.id
    end

    test "create_from_sponsorship/1 with a nil sponsorship still saves the impression", %{
      property: property
    } do
      valid_attrs = @valid_attrs |> Map.merge(%{property_id: property.id})
      {:ok, %Impression{} = impression} = Impressions.create_impression(valid_attrs)
      assert !is_nil(impression.id)
    end

    test "update_impression/2 with valid data updates the impression", %{impression: impression} do
      assert {:ok, impression} = Impressions.update_impression(impression, @update_attrs)
      assert %Impression{} = impression
      assert impression.browser == "some updated browser"
      assert impression.city == "some updated city"
      assert impression.country == "some updated country"
      assert impression.device_type == "some updated device_type"
      assert impression.ip == "some updated ip"
      assert impression.latitude == Decimal.new("456.7")
      assert impression.longitude == Decimal.new("456.7")
      assert impression.os == "some updated os"
      assert impression.postal_code == "some updated postal_code"
      assert impression.region == "some updated region"
    end

    test "update_impression/2 with invalid data returns error changeset", %{
      impression: impression
    } do
      {:error, %Ecto.Changeset{}} = Impressions.update_impression(impression, @invalid_attrs)

      assert impression.browser == Impressions.get_impression!(impression.id).browser
    end

    test "delete_impression/1 deletes the impression", %{impression: impression} do
      {:ok, %Impression{}} = Impressions.delete_impression(impression)
      assert_raise Ecto.NoResultsError, fn -> Impressions.get_impression!(impression.id) end
    end
  end
end
