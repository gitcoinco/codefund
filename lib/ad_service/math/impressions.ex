defmodule AdService.Math.Impressions do
  defguard valid_cpm_and_budget?(cpm, budget)
           when is_number(cpm) and is_number(budget) and cpm > 0

  @doc """
  Calculates the total number impressions for the given CPM and budget.

  ## Examples

    iex>AdService.Math.Impressions.total_impressions_for_budget(3.0, 1200.0)
    400000

    iex>AdService.Math.Impressions.total_impressions_for_budget(0, 100)
    0

    iex>AdService.Math.Impressions.total_impressions_for_budget(nil, nil)
    0
  """
  @spec total_impressions_for_budget(float, float) :: integer
  def total_impressions_for_budget(cpm, budget) when valid_cpm_and_budget?(cpm, budget) do
    (budget / cpm * 1000) |> round()
  end

  def total_impressions_for_budget(_, _), do: 0
end
