defmodule CodeFundWeb.API.AudienceMetricsController do
  use CodeFundWeb, :controller

  def index(conn, %{"filters" => property_filters}) do
    property_filters =
      for {key, val} <- property_filters, into: [], do: {String.to_existing_atom(key), val}

    conn
    |> json(AdService.Query.ForAudienceCreation.metrics(property_filters))
  end
end
