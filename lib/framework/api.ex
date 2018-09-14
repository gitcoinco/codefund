defmodule Framework.API do
  @spec generate_api_key() :: binary()
  def generate_api_key() do
    :crypto.strong_rand_bytes(20) |> Base.url_encode64() |> binary_part(0, 20)
  end
end
