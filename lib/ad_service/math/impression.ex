defmodule AdService.Math.Impression do
  @doc """
    Calculates the total number impressions for the given eCPM and total_spend.

    ## Examples

      iex>AdService.Math.Impression.total_impressions_for_total_spend(3.0, 1200.0)
      400000

      iex>AdService.Math.Impression.total_impressions_for_total_spend(4.2, 2300.0)
      547619

      iex>AdService.Math.Impression.total_impressions_for_total_spend(0.0, 100)
      0

      iex>AdService.Math.Impression.total_impressions_for_total_spend(3.0, 0.0)
      0

      iex>AdService.Math.Impression.total_impressions_for_total_spend(0.0, 0.0)
      0

      iex>AdService.Math.Impression.total_impressions_for_total_spend(0.0, 100)
      0
  """

  @spec total_impressions_for_total_spend(float, float) :: integer
  def total_impressions_for_total_spend(ecpm, total_spend) when ecpm > 0.0 do
    (total_spend / ecpm * 1000) |> round()
  end

  def total_impressions_for_total_spend(_, _), do: 0
end
