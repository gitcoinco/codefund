defmodule AdService.AdvertisementImpression do
  @derive Jason.Encoder
  defstruct small_image_url: "",
            large_image_url: "",
            link: "",
            images: [],
            description: "",
            house_ad: false,
            pixel: "",
            poweredByLink: "",
            headline: "",
            reason: nil

  @spec new(
          {:ok | :error,
           {%AdService.Impression.Details{}, %AdService.UnrenderedAdvertisement{}}
           | {%AdService.Impression.Details{}}}
        ) :: %__MODULE__{}
  def new({:ok, {impression_details, unrendered_advertisement}}) do
    params = %{
      small_image_url: AdService.ImageAsset.fetch_url(unrendered_advertisement.images, "small"),
      large_image_url: AdService.ImageAsset.fetch_url(unrendered_advertisement.images, "large"),
      link: "https://#{impression_details.conn.host}/c/#{impression_details.id}",
      description: unrendered_advertisement.body,
      house_ad: impression_details.house_ad,
      images: unrendered_advertisement.images,
      pixel: "//#{impression_details.conn.host}/p/#{impression_details.id}/pixel.png",
      poweredByLink: "https://codefund.io?utm_content=#{unrendered_advertisement.campaign_id}",
      headline: unrendered_advertisement.headline
    }

    struct(__MODULE__, params)
  end

  def new({:error, {impression_details}}) do
    params = %{
      pixel: "//#{impression_details.conn.host}/p/#{impression_details.id}/pixel.png",
      poweredByLink: "https://codefund.io?utm_content=",
      reason: impression_details.error.human_readable_message
    }

    struct(__MODULE__, params)
  end

  def new({:error, :is_bot}) do
    params = %{
      poweredByLink: "https://codefund.io?utm_content=",
      reason: "CodeFund does not have an advertiser for you at this time"
    }

    struct(__MODULE__, params)
  end
end
