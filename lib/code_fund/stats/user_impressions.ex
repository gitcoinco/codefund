defmodule CodeFund.Stats.UserImpressions do
  use GenServer
  alias CodeFund.Query.UserImpression, as: Query
  alias CodeFund.Repo

  @refresh_interval (System.get_env("USER_IMPRESSION_STATS_REFRESH_INTERVAL_IN_MINUTES") || 60)
                    |> to_string
                    |> String.to_integer()
                    |> :timer.minutes()

  defmodule State do
    defstruct impression_count: 0,
              click_count: 0,
              click_rate: 0.0,
              paid_impression_count: 0,
              paid_click_count: 0,
              paid_click_rate: 0.0,
              distribution_amount: 0.0,
              refreshed_at: nil
  end

  # Client API

  def last_thirty_days() do
    GenServer.call(__MODULE__, :stats)
  end

  # Invoked by the Supervisor process
  def start_link do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  # Inside the spawned GenServer process
  def init(state) do
    schedule_refresh(:timer.seconds(5))
    {:ok, state}
  end

  def handle_call(:stats, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh, _state) do
    schedule_refresh(@refresh_interval)
    {:noreply, fetch_stats()}
  end

  # Internals

  defp schedule_refresh(delay) do
    Process.send_after(self(), :refresh, delay)
  end

  defp fetch_stats do
    impression_count = impression_count_for_last_thirty_days()
    paid_impression_count = paid_impression_count_for_last_thirty_days()
    click_count = click_count_for_last_thirty_days()
    paid_click_count = paid_click_count_for_last_thirty_days()

    %State{
      impression_count: impression_count,
      click_count: click_count,
      click_rate: click_rate(impression_count, click_count),
      paid_impression_count: paid_impression_count,
      paid_click_count: paid_click_count,
      paid_click_rate: click_rate(paid_impression_count, paid_click_count),
      distribution_amount: distribution_amount_for_last_thirty_days(),
      refreshed_at: Timex.now()
    }
  end

  defp click_rate(impression_count, click_count) do
    case click_count do
      0 -> 0.0
      _ -> click_count / impression_count
    end
  end

  defp impression_count_for_last_thirty_days() do
    Query.impression_count_for_last_thirty_days() |> Repo.one() || 0
  end

  defp paid_impression_count_for_last_thirty_days() do
    Query.paid_impression_count_for_last_thirty_days() |> Repo.one() || 0
  end

  defp click_count_for_last_thirty_days do
    Query.click_count_for_last_thirty_days() |> Repo.one() || 0
  end

  defp paid_click_count_for_last_thirty_days do
    Query.paid_click_count_for_last_thirty_days() |> Repo.one() || 0
  end

  defp distribution_amount_for_last_thirty_days do
    Query.distribution_amount_for_last_thirty_days() |> Repo.one() || 0.0
  end
end
