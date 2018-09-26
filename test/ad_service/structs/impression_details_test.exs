defmodule AdService.Impression.DetailsTest do
  use CodeFundWeb.ConnCase
  import CodeFund.Factory

  setup do
    conn = build_conn()

    impression_details =
      AdService.Impression.Details.new(conn, insert(:property), insert(:campaign))

    {:ok, %{impression_details: impression_details, conn: conn}}
  end

  describe "new/3" do
    test "it returns the error code for the corresponding atom", %{conn: conn} do
      assert AdService.Impression.Details.new(conn, "property", "campaign") ==
               %AdService.Impression.Details{
                 browser_details: %AdService.BrowserDetails{
                   height: nil,
                   width: nil
                 },
                 campaign: "campaign",
                 conn: conn,
                 country: "US",
                 error: %AdService.Impression.ErrorStruct{
                   human_readable_message: nil,
                   reason_atom: nil
                 },
                 financials: %AdService.Impression.Financials{
                   distribution_amount: nil,
                   revenue_amount: nil
                 },
                 host: "www.example.com",
                 house_ad: false,
                 ip: "127.0.0.1",
                 property: "property"
               }
    end
  end

  describe "put_country/2" do
    test "it updates the country in the impression details", %{
      impression_details: impression_details
    } do
      assert impression_details.country == "US"
      assert AdService.Impression.Details.put_country(impression_details, "UK").country == "UK"
    end
  end

  describe "flag_house_ad/2" do
    test "it sets house_ad to true and updates the campaign in the impression details", %{
      impression_details: impression_details
    } do
      refute impression_details.house_ad

      campaign = insert(:campaign)
      updated_struct = AdService.Impression.Details.flag_house_ad(impression_details, campaign)
      assert updated_struct.house_ad == true
      assert updated_struct.campaign == campaign
    end
  end

  describe "put_error/2" do
    test "it doesn't update the errors struct in the impression details if no error occurred", %{
      impression_details: impression_details
    } do
      assert impression_details.error == %AdService.Impression.ErrorStruct{}

      updated_struct = AdService.Impression.Details.put_error(impression_details, nil)
      assert updated_struct.error == %AdService.Impression.ErrorStruct{}
    end

    test "it updates the errors struct in the impression details if an error occurred", %{
      impression_details: impression_details
    } do
      assert impression_details.error == %AdService.Impression.ErrorStruct{}

      updated_struct =
        AdService.Impression.Details.put_error(impression_details, :property_inactive)

      assert updated_struct.error == %AdService.Impression.ErrorStruct{
               human_readable_message: "This property is not currently active - code: 0",
               reason_atom: :property_inactive
             }
    end
  end

  describe "put_financials/2" do
    test "it updates the financials struct based on the campaign set", %{
      impression_details: impression_details
    } do
      assert impression_details.financials == %AdService.Impression.Financials{}

      updated_struct =
        impression_details
        |> struct(%{campaign: insert(:campaign)})
        |> AdService.Impression.Details.put_financials()

      assert updated_struct.financials == %AdService.Impression.Financials{
               distribution_amount: 0.0012,
               revenue_amount: 0.002
             }
    end
  end

  describe "put_browser_details/3" do
    test "it updates the browser details struct with height and width passed in", %{
      impression_details: impression_details
    } do
      assert impression_details.browser_details == %AdService.BrowserDetails{}

      updated_struct =
        impression_details
        |> AdService.Impression.Details.put_browser_details(100, 200)

      assert updated_struct.browser_details == %AdService.BrowserDetails{height: 100, width: 200}
    end
  end

  describe "save/1" do
    test "it serializes and saves the impression details struct as an impression", %{conn: conn} do
      property = insert(:property)
      campaign = insert(:campaign)

      {:ok, saved_impression} =
        AdService.Impression.Details.new(conn, property, campaign)
        |> AdService.Impression.Details.put_country("UK")
        |> AdService.Impression.Details.put_financials()
        |> AdService.Impression.Details.put_browser_details(100, 200)
        |> AdService.Impression.Details.save()

      refute is_nil(saved_impression.id)
      assert saved_impression.__struct__ == AdService.Impression.Details
      assert saved_impression.property.id == property.id
      assert saved_impression.campaign.id == campaign.id
      assert saved_impression.saved
      assert saved_impression.financials.revenue_amount == 0.002
      assert saved_impression.financials.distribution_amount == 0.0012
      refute saved_impression.house_ad

      assert saved_impression.browser_details == %AdService.BrowserDetails{
               height: 100,
               width: 200
             }
    end

    test "it serializes and saves the impression details struct as an impression with errors", %{
      conn: conn
    } do
      property = insert(:property)
      campaign = insert(:campaign)

      {:ok, saved_impression} =
        AdService.Impression.Details.new(conn, property, insert(:campaign))
        |> AdService.Impression.Details.flag_house_ad(campaign)
        |> AdService.Impression.Details.put_error(:property_inactive)
        |> AdService.Impression.Details.save()

      refute is_nil(saved_impression.id)
      assert saved_impression.__struct__ == AdService.Impression.Details
      assert saved_impression.house_ad == true
      assert saved_impression.property.id == property.id
      assert saved_impression.campaign.id == campaign.id
      assert saved_impression.saved

      assert saved_impression.financials ==
               %AdService.Impression.Financials{distribution_amount: nil, revenue_amount: nil}

      assert saved_impression.error == %AdService.Impression.ErrorStruct{
               human_readable_message:
                 "This property is not currently active - code: #{
                   AdService.Impression.Errors.fetch_code(:property_inactive)
                 }",
               reason_atom: :property_inactive
             }
    end

    test "it serializes and saves the impression details struct as an impression with errors if no campaign is assigned",
         %{conn: conn} do
      property = insert(:property)

      {:ok, saved_impression} =
        AdService.Impression.Details.new(conn, property, nil)
        |> AdService.Impression.Details.put_error(:property_inactive)
        |> AdService.Impression.Details.save()

      refute is_nil(saved_impression.id)
      assert saved_impression.__struct__ == AdService.Impression.Details
      assert saved_impression.property.id == property.id
      refute saved_impression.campaign
      assert saved_impression.saved
      assert saved_impression.saved == true

      assert saved_impression.financials ==
               %AdService.Impression.Financials{distribution_amount: nil, revenue_amount: nil}

      assert saved_impression.error == %AdService.Impression.ErrorStruct{
               human_readable_message:
                 "This property is not currently active - code: #{
                   AdService.Impression.Errors.fetch_code(:property_inactive)
                 }",
               reason_atom: :property_inactive
             }
    end
  end
end
