defmodule CodeFundWeb.CreativeController do
  use CodeFundWeb, :controller
  use Framework.Controller
  alias Framework.Phoenix.Form.Helpers, as: FormHelpers
  alias CodeFund.Schema.Asset
  use Framework.Controller.Stub.Definitions, [:index, :delete]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  defconfig do
    [schema: "Creative"]
  end

  defstub new do
    before_hook(&assign_assets/2)
  end

  defstub create do
    inject_params(&CodeFundWeb.Hooks.Shared.join_to_current_user_id/2)
    |> error(&assign_assets/2)
  end

  defstub show do
    before_hook(&fetch_image_urls/2)
  end

  defstub update do
    error(&assign_assets/2)
  end

  defstub edit do
    before_hook(&fetch_image_urls/2)
    |> error(&assign_assets/2)
  end

  defp fetch_image_urls(conn, params) do
    %CodeFund.Schema.Creative{
      small_image_asset: %Asset{image_object: small_image_object},
      large_image_asset: %Asset{image_object: large_image_object}
    } = CodeFund.Creatives.get_creative!(params["id"])

    [
      small_image_url: Framework.FileStorage.url(small_image_object),
      large_image_url: Framework.FileStorage.url(large_image_object)
    ]
    |> Enum.concat(assign_assets(conn, nil))
  end

  defp assign_assets(conn, _) do
    assets =
      case conn.assigns.current_user.roles |> CodeFund.Users.has_role?(["admin"]) do
        true -> CodeFund.Assets.list_assets()
        false -> CodeFund.Assets.by_user_id(conn.assigns.current_user.id)
      end

    [assets: assets |> FormHelpers.repo_objects_to_options()]
  end
end
