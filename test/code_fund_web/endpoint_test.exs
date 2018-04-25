defmodule CodeFundWeb.EndpointTest do
  use ExUnit.Case

  describe "url/0" do
    test "it returns a relative url in Mix.env :dev" do
      Mix.env(:dev)
      assert CodeFundWeb.Endpoint.url() == "http://localhost:4001"
      Mix.env(:test)
    end

    test "it returns a relative url in Mix.env :prod with no port number" do
      Mix.env(:prod)
      assert CodeFundWeb.Endpoint.url() == "http://localhost"
      Mix.env(:test)
    end
  end
end
