defmodule AdService.UnprocessedImageAsset do
  defstruct [:size_descriptor, :asset]
end

defmodule AdService.ImageAsset do
  @enforce_keys [:size_descriptor, :width, :height]
  @derive Jason.Encoder
  defstruct [:size_descriptor, :width, :height, :url]

  @types %{
    "small" => %{height: 200, width: 200},
    "large" => %{height: 200, width: 280},
    "wide" => %{height: 512, width: 320}
  }

  @spec new(String.t(), %CodeFund.Schema.Asset{}) :: %__MODULE__{}
  def new(size_descriptor, asset \\ %CodeFund.Schema.Asset{}) do
    sanitized_params =
      asset
      |> Map.take([:height, :width, :image_object])
      |> Enum.reject(fn {_, v} -> is_nil(v) end)
      |> Enum.into(%{})

    struct_attrs =
      @types
      |> Map.get(size_descriptor)
      |> Map.merge(sanitized_params)
      |> Map.merge(%{
        size_descriptor: size_descriptor,
        url: Framework.FileStorage.url(asset.image_object)
      })

    struct(__MODULE__, struct_attrs)
  end

  @spec fetch_url([%AdService.ImageAsset{}], String.t()) :: String.t()
  def fetch_url(images, size_descriptor) do
    images
    |> Enum.find(fn elem -> elem.size_descriptor == size_descriptor end)
    |> Map.get(:url)
  end
end
