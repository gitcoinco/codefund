defmodule AdService.Advertisement do
  defstruct [
    :body,
    :ecpm,
    :campaign_id,
    :headline,
    :image_url,
    :campaign_name,
    :small_image_object,
    :small_image_bucket,
    :large_image_object,
    :large_image_bucket
  ]
end
