defmodule CodeFund.AssetsTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  alias CodeFund.Assets
  alias CodeFund.Schema.Asset

  setup do
    asset = insert(:asset)
    {:ok, %{asset: asset}}
  end

  describe "assets" do
    test "paginate_assets/1 returns paginated results" do
      user = insert(:user)
      insert_list(25, :asset, user: user)
      insert_list(25, :asset)

      {:ok, results} = Assets.paginate_assets(user)
      assert results.distance == 5
      assert results.page_number == 1
      assert results.page_size == 15
      assert results.sort_direction == "desc"
      assert results.sort_field == "inserted_at"
      assert results.total_entries == 25
      assert results.total_pages == 2
      assert length(results.assets) == 15
    end

    test "by_user_id/1 returns assets by user" do
      user = insert(:user)
      insert_list(25, :asset, user: user)
      insert_list(25, :asset)

      assert Assets.by_user_id(user.id) |> length == 25
    end

    test "list_assets/0 returns all assets", %{asset: asset} do
      assets = Assets.list_assets()
      assert assets |> Enum.count() == 1
      assert assets |> List.first() |> Map.get(:id) == asset.id
      assert assets |> List.first() |> Map.get(:__struct__) == Asset
    end

    test "get_asset!/1 returns the asset with given id", %{asset: asset} do
      insert(:asset)
      assert Assets.get_asset!(asset.id).id == asset.id
    end

    test "create_asset/1 with valid data creates a asset" do
      assert {:ok, %Asset{} = asset} = Assets.create_asset(params_with_assocs(:asset))

      assert asset.name == "Stub Image"
      assert asset.image_bucket == "stub"
      assert asset.image_object =~ "_mock.jpg"
    end

    test "create_asset/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               params_with_assocs(:asset) |> Map.delete(:name) |> Assets.create_asset()
    end

    test "update_asset/2 with valid data updates the asset", %{asset: asset} do
      assert {:ok, asset} = Assets.update_asset(asset, %{name: "New Name"})
      assert %Asset{} = asset
      assert asset.name == "New Name"
    end

    test "update_asset/2 with invalid data returns error changeset", %{asset: asset} do
      assert {:error, %Ecto.Changeset{}} = Assets.update_asset(asset, %{name: ""})
      assert Assets.get_asset!(asset.id).name == "Stub Image"
    end

    test "delete_asset/1 deletes the asset" do
      asset = insert(:asset)
      assert {:ok, %Asset{}} = Assets.delete_asset(asset)
      assert_raise Ecto.NoResultsError, fn -> Assets.get_asset!(asset.id) end
    end

    test "change_asset/1 returns a asset changeset", %{asset: asset} do
      assert %Ecto.Changeset{} = Assets.change_asset(asset)
    end
  end
end
