defmodule AdService.Tracking.AnalyticsManager do
  use GenServer
  alias CodeFund.Schema.Impression
  import Staccato.Hit

  @spec start_link() :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec init(:ok) :: {:ok, [{:tracker, map()}, ...]}
  def init(:ok) do
    case Application.get_env(:code_fund, __MODULE__)[:google_analytics_property_id] do
      nil ->
        raise "Google analytics property ID for impression tracking must be set"

      property_id ->
        {:ok, :ga_geoids} = AdService.Tracking.GeoIDETSHandler.import_geo_id_csv(:ga_geoids)

        tracker = Staccato.tracker(property_id, return_unique_client_id(), ssl: true)

        {:ok, [tracker: tracker]}
    end
  end

  @doc """
  Sends event to google analytics
  """
  @spec send_event(%Impression{}) :: any
  def send_event(%Impression{} = impression) do
    GenServer.cast(AdService.Tracking.AnalyticsManager, {:event, impression})
  end

  @spec handle_cast({:event, %Impression{}}, tracker: %Staccato.Tracker{}) ::
          {:noreply, [tracker: %Staccato.Tracker{}]}
  def handle_cast({:event, %Impression{} = impression}, tracker: tracker) do
    with {:ok, geo_id} <-
           AdService.Tracking.GeoIDETSHandler.fetch_geo_id(
             :ga_geoids,
             impression.city,
             impression.region,
             impression.country
           ) do
      track_impression(tracker, impression, geo_id)
    else
      {:error, :no_matching_geo_id} ->
        track_impression(tracker, impression, nil)
    end

    tracker = tracker |> set_client_id()
    {:noreply, [tracker: tracker]}
  end

  @spec track_impression(%Staccato.Tracker{}, %Impression{}, nil | String.t()) ::
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()}
  defp track_impression(tracker, impression, nil) do
    tracker
    |> event(params_for_tracking(impression))
    |> track!()
  end

  defp track_impression(tracker, impression, geo_id) do
    params =
      impression
      |> params_for_tracking()
      |> Keyword.merge([{:geographical_id, geo_id}])

    tracker
    |> event(params)
    |> track!()
  end

  @spec set_client_id(%Staccato.Tracker{}) :: %Staccato.Tracker{}
  defp set_client_id(%Staccato.Tracker{} = tracker),
    do: tracker |> Map.put(:client_id, return_unique_client_id())

  @spec return_unique_client_id() :: String.t()
  defp return_unique_client_id(), do: "AnalyticsManager_#{UUID.uuid4()}"

  @spec params_for_tracking(%Impression{}) :: Keyword.t()
  defp params_for_tracking(impression),
    do: [
      category: impression.property.name,
      action: impression.campaign.name,
      label: "impression",
      value: 1,
      user_id: UUID.uuid4(),
      user_ip: impression.ip,
      user_agent: impression.user_agent
    ]
end
