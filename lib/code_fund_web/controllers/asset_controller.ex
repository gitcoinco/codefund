defmodule CodeFundWeb.AssetController do
  use CodeFundWeb, :controller
  use Framework.Controller
  use Framework.Controller.Stub.Definitions, [:index, :delete]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  defconfig do
    [schema: "Asset"]
  end

  defstub new do
    assigns(multipart_form: true)
  end

  defstub create do
    inject_params(&CodeFundWeb.Hooks.Shared.join_to_current_user_id/2)
    |> error(&multipart_form/2)
  end

  defstub show do
    before_hook(&fetch_image_urls/2)
  end

  defstub edit do
    assigns(multipart_form: true)
    |> before_hook(&fetch_image_urls/2)
  end

  defstub update do
    error(&multipart_form/2)
  end

  defp multipart_form(_conn, _params), do: [multipart_form: true]

  defp fetch_image_urls(_conn, params) do
    %CodeFund.Schema.Asset{
      image_object: image_object
    } = CodeFund.Assets.get_asset!(params["id"])

    [
      image_url: Framework.FileStorage.url(image_object)
    ]
  end
end
