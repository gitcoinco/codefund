defmodule AdService.ResponseMap do
  alias AdService.Advertisement

  def for_success(
        %Advertisement{
          body: body,
          campaign_id: campaign_id,
          headline: headline,
          small_image_object: small_image_object,
          large_image_object: large_image_object
        },
        conn,
        impression_id,
        house_ad \\ false
      ) do
    %{
      small_image_url: Framework.FileStorage.url(small_image_object),
      large_image_url: Framework.FileStorage.url(large_image_object),
      link: "https://#{conn.host}/c/#{impression_id}",
      description: body,
      house_ad: house_ad,
      pixel: "//#{conn.host}/p/#{impression_id}/pixel.png",
      poweredByLink: "https://codefund.io?utm_content=#{campaign_id}",
      headline: headline
    }
  end

  def for_error(reason_message, pixel_url \\ "") do
    %{
      link: "",
      headline: "",
      description: "",
      pixel: pixel_url,
      house_ad: false,
      large_image_url: "",
      small_image_url: "",
      poweredByLink: "https://codefund.io?utm_content=",
      reason: reason_message
    }
  end
end
