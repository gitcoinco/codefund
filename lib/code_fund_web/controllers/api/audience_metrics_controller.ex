defmodule CodeFundWeb.API.AudienceMetricsController do
  use CodeFundWeb, :controller

  def index(conn, %{"filters" => property_filters}) do
    property_filters =
      for {key, val} <- property_filters, into: [], do: {String.to_existing_atom(key), val}

    property_filters =
      case property_filters |> Keyword.has_key?(:included_countries) do
        true ->
          property_filters

        false ->
          property_filters
          |> Keyword.put(
            :included_countries,
            Keyword.values(Framework.Geolocation.Countries.list())
          )
      end

    conn
    |> json(AdService.Query.ForAudienceCreation.metrics(property_filters))
  end
end
