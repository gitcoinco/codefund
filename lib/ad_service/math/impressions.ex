defmodule AdService.Math.Impressions do
  defguardp valid_cpm_and_budget?(cpm, budget)
            when is_float(cpm) and is_float(budget) and cpm > 0.0

  @doc """
  Calculates the total number impressions for the given CPM and budget.

  ## Examples

    iex>AdService.Math.Impressions.total_impressions_for_budget(3.0, 1200.0)
    400000

    iex>AdService.Math.Impressions.total_impressions_for_budget(4.2, 2300.0)
    547619

    iex>AdService.Math.Impressions.total_impressions_for_budget("", 100)
    0

    iex>AdService.Math.Impressions.total_impressions_for_budget(3.0, "")
    0

    iex>AdService.Math.Impressions.total_impressions_for_budget("", "")
    0

    iex>AdService.Math.Impressions.total_impressions_for_budget(0.0, 100)
    0

    iex>AdService.Math.Impressions.total_impressions_for_budget(3.0, nil)
    0

    iex>AdService.Math.Impressions.total_impressions_for_budget(nil, 100)
    0

    iex>AdService.Math.Impressions.total_impressions_for_budget(nil, nil)
    0
  """
  @spec total_impressions_for_budget(float, float) :: integer
  def total_impressions_for_budget(cpm, budget) when valid_cpm_and_budget?(cpm, budget) do
    (budget / cpm * 1000) |> round()
  end

  #def total_impressions_for_budget(0.0, _), do: 0

  def total_impressions_for_budget(cpm, budget) when not is_nil(cpm) and not is_nil(budget) do
    total_impressions_for_budget(value_to_float(cpm), value_to_float(budget))
  end

  def total_impressions_for_budget(_, _), do: 0

  defp value_to_float(value) when is_float(value), do: value

  defp value_to_float(value) do
    case Float.parse(to_string(value)) do
      {f, _} -> f
      _ -> nil
    end
  end
end
