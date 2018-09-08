defmodule AdService.Tracking.GeoIDETSHandlerTest do
  use ExUnit.Case

  describe "import_geo_id_csv/1" do
    test "it imports the geoid csv into an ets table" do
      assert {:ok, :ga_geoid_test} ==
               AdService.Tracking.GeoIDETSHandler.import_geo_id_csv(:ga_geoid_test)

      assert [["1014448"]] == :ets.match(:ga_geoid_test, {:"$1", "Boulder", "Colorado", :_, "US"})
    end
  end

  describe "fetch_geo_id/4" do
    test "it returns the geo_id for a location" do
      assert {:ok, "1014448"} ==
               AdService.Tracking.GeoIDETSHandler.fetch_geo_id(
                 :ga_geoids,
                 "Boulder",
                 "Colorado",
                 "US"
               )
    end

    test "it can return geo_id for partial locations" do
      assert {:ok, "1014448"} ==
               AdService.Tracking.GeoIDETSHandler.fetch_geo_id(
                 :ga_geoids,
                 "Boulder",
                 "Colorado",
                 ""
               )
    end

    test "it returns an error if a match isn't found for a location" do
      assert {:error, :no_matching_geo_id} ==
               AdService.Tracking.GeoIDETSHandler.fetch_geo_id(
                 :ga_geoids,
                 "Wonderland",
                 "Alice's",
                 "TY"
               )
    end

    test "it picks the first match if a match results in multiples" do
      assert {:ok, "9024058"} ==
               AdService.Tracking.GeoIDETSHandler.fetch_geo_id(
                 :ga_geoids,
                 "",
                 "Kansas",
                 "US"
               )
    end
  end
end
