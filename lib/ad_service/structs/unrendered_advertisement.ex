defmodule AdService.UnrenderedAdvertisement do
  defstruct [
    :body,
    :ecpm,
    :campaign_id,
    :headline,
    :campaign_name,
    :images
  ]

  @spec all(Ecto.Query.t()) :: [%__MODULE__{}]
  def all(query) do
    results =
      query
      |> CodeFund.Repo.all()

    for result <- results do
      images =
        Enum.map(
          Enum.reject(result.images, fn v -> is_nil(v.asset) end),
          &AdService.ImageAsset.new(&1.size_descriptor, &1.asset)
        )

      result
      |> Map.merge(%{images: images})
    end
  end

  @spec all(Ecto.Query.t()) :: %__MODULE__{}
  def one(query) do
    query
    |> all
    |> List.first()
  end
end
