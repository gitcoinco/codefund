defmodule CodeFundWeb.API.V1.Property.ImpressionController do
  use CodeFundWeb, :controller

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"property_id" => property_id, "ip_address" => ip} = params)
      when not is_nil(ip) do
    payload =
      conn
      |> AdService.Server.serve(property_id, params)

    render(conn, CodeFundWeb.API.AdServeView, "details.json", payload: payload)
  end

  def create(conn, _) do
    conn
    |> put_status(422)
    |> json(%{error: "Client's IP Address is required (`ip_address` parameter in post body)"})
  end
end
