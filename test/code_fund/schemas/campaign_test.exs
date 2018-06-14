defmodule CodeFund.Schema.CampaignTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Campaign
  import CodeFund.Factory

  describe "campaigns" do
    setup do
      valid_attrs =
        build(
          :campaign,
          user_id: insert(:user).id,
          creative_id: insert(:creative).id,
          start_date: "2018-01-01",
          end_date: "2018-01-01"
        )
        |> Map.from_struct()

      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      valid_attrs = valid_attrs |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
      assert Campaign.changeset(%Campaign{}, valid_attrs).valid?
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.required_attribute_test(Campaign, Campaign.required(), valid_attrs)
    end

    test "changeset with invalid redirect_url or fraud_check_url", %{valid_attrs: valid_attrs} do
      invalid_attrs =
        valid_attrs
        |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
        |> Map.put("redirect_url", "narf")

      changeset = CodeFund.Schema.Campaign.changeset(%Campaign{}, invalid_attrs)
      refute changeset.valid?

      assert changeset.errors == [
               {:redirect_url, {"is missing a scheme (e.g. https)", [validation: :format]}}
             ]
    end
  end
end
