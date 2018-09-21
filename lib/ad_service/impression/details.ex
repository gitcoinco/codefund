defmodule AdService.Impression.ErrorStruct do
  defstruct [:human_readable_message, :reason_atom]
end

defmodule AdService.Impression.Financials do
  defstruct [:revenue_amount, :distribution_amount]
end

defmodule AdService.BrowserDetails do
  defstruct [:height, :width, :user_agent]
end

defmodule AdService.Impression.Details do
  alias AdService.Impression.Errors, as: ImpressionErrors
  alias CodeFund.Impressions
  import CodeFund.Reporter

  defstruct host: nil,
            conn: nil,
            property: nil,
            campaign: nil,
            error: %AdService.Impression.ErrorStruct{},
            ip: nil,
            house_ad: false,
            country: nil,
            financials: %AdService.Impression.Financials{},
            browser_details: %AdService.BrowserDetails{}

  @spec new(Plug.Conn.t(), %CodeFund.Schema.Property{}, %CodeFund.Schema.Campaign{} | nil) ::
          %__MODULE__{}
  def new(conn, property, campaign) do
    {:ok, country} = conn.remote_ip |> Framework.Geolocation.find_by_ip(:country)
    ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")

    %__MODULE__{
      property: property,
      conn: conn,
      host: conn.host,
      campaign: campaign,
      ip: ip,
      country: country
    }
  end

  @spec put_country(%__MODULE__{}, String.t()) :: %__MODULE__{}
  def put_country(%__MODULE__{} = struct, country) do
    struct |> struct(%{country: country})
  end

  @spec flag_house_ad(%__MODULE__{}, %CodeFund.Schema.Campaign{}) :: %__MODULE__{}
  def flag_house_ad(%__MODULE__{} = struct, campaign),
    do: struct |> struct(%{house_ad: true, campaign: campaign})

  @spec put_error(%__MODULE__{}, atom | nil) :: %__MODULE__{}
  def put_error(%__MODULE__{} = struct, nil), do: struct

  def put_error(%__MODULE__{} = struct, error_atom) do
    human_readable_message =
      error_atom
      |> ImpressionErrors.fetch_human_readable_message()

    struct
    |> struct(%{
      error: %AdService.Impression.ErrorStruct{
        human_readable_message: human_readable_message,
        reason_atom: error_atom
      }
    })
  end

  @spec put_financials(%__MODULE__{}) :: %__MODULE__{}
  def put_financials(%__MODULE__{} = struct) do
    struct
    |> struct(%{
      financials: %AdService.Impression.Financials{
        revenue_amount: AdService.Math.CPM.revenue_amount(struct.campaign),
        distribution_amount:
          AdService.Math.CPM.distribution_amount(struct.campaign, struct.property.user)
      }
    })
  end

  @spec put_browser_details(%__MODULE__{}, integer | nil, integer | nil) :: %__MODULE__{}
  def put_browser_details(%__MODULE__{} = struct, height \\ nil, width \\ nil, user_agent \\ nil) do
    struct
    |> struct(%{
      browser_details: %AdService.BrowserDetails{
        height: height,
        width: width,
        user_agent: user_agent
      }
    })
  end

  @spec save(%__MODULE__{}) :: {:ok, %CodeFund.Schema.Impression{}}
  def save(%__MODULE__{} = impression_details) do
    campaign_id =
      case impression_details.campaign do
        nil -> nil
        campaign -> campaign.id
      end

    map =
      impression_details
      |> Map.from_struct()
      |> Map.merge(%{
        property_id: impression_details.property.id,
        campaign_id: campaign_id,
        revenue_amount: impression_details.financials.revenue_amount,
        distribution_amount: impression_details.financials.distribution_amount,
        error_code: impression_details.error.reason_atom |> ImpressionErrors.fetch_code(),
        browser_height: impression_details.browser_details.height,
        browser_width: impression_details.browser_details.width,
        user_agent: impression_details.browser_details.user_agent
      })

    result = map |> Impressions.create_impression()

    case result do
      {:ok, _} ->
        result

      {:error, _} ->
        report(:warning, "Country failed -- {map.country}")
        result
    end
  end
end
