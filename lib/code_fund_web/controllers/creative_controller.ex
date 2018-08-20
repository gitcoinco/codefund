defmodule CodeFundWeb.CreativeController do
  use CodeFundWeb, :controller
  use Framework.Controller
  use Framework.Controller.Stub.Definitions, [:index, :delete]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  defconfig do
    [schema: "Creative"]
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
    %CodeFund.Schema.Creative{
      small_image_object: small_image_object,
      small_image_bucket: small_image_bucket,
      large_image_object: large_image_object,
      large_image_bucket: large_image_bucket
    } = CodeFund.Creatives.get_creative!(params["id"])

    [
      small_image_url: Framework.FileStorage.url(small_image_bucket, small_image_object),
      large_image_url: Framework.FileStorage.url(large_image_bucket, large_image_object)
    ]
  end
end
