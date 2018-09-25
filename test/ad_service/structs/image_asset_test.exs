defmodule AdService.ImageAssetTest do
  use CodeFund.DataCase
  import CodeFund.Factory
  alias AdService.ImageAsset

  setup do
    [cdn_host: cdn_host] = Application.get_env(:code_fund, Framework.FileStorage)
    {:ok, %{asset: insert(:asset, height: nil, width: nil), cdn_host: cdn_host}}
  end

  describe "new/2" do
    test "it sets defaults for sizes and ignores null values", %{asset: asset, cdn_host: cdn_host} do
      assert ImageAsset.new("small", asset) ==
               %ImageAsset{
                 size_descriptor: "small",
                 height: 200,
                 width: 200,
                 url: "https://#{cdn_host}/image.jpg"
               }

      assert ImageAsset.new("large", asset) ==
               %ImageAsset{
                 size_descriptor: "large",
                 height: 200,
                 width: 280,
                 url: "https://#{cdn_host}/image.jpg"
               }

      assert ImageAsset.new("wide", asset) ==
               %ImageAsset{
                 size_descriptor: "wide",
                 height: 600,
                 width: 300,
                 url: "https://#{cdn_host}/image.jpg"
               }
    end

    test "it accepts the height and width from a saved asset", %{cdn_host: cdn_host} do
      asset = insert(:asset, height: 300, width: 400)

      assert ImageAsset.new("small", asset) ==
               %ImageAsset{
                 size_descriptor: "small",
                 height: 300,
                 width: 400,
                 url: "https://#{cdn_host}/image.jpg"
               }
    end

    test "it ignores null values passed in", %{cdn_host: cdn_host} do
      large_asset = insert(:asset, image_object: "large.jpg")
      small_asset = insert(:asset, image_object: "small.jpg")

      image_assets = [
        ImageAsset.new("small", small_asset),
        ImageAsset.new("large", large_asset)
      ]

      assert ImageAsset.fetch_url(image_assets, "small") == "https://#{cdn_host}/small.jpg"
    end
  end
end
