defmodule CodeFund.Stats.UserImpressions do
  use GenServer
  use CodeFundWeb, :query
  alias CodeFund.Schema.UserImpression

  @refresh_interval (System.get_env("USER_IMPRESSION_STATS_REFRESH_INTERVAL_IN_MINUTES") || 60)
                    |> to_string
                    |> String.to_integer()
                    |> :timer.minutes()

  defmodule State do
    defstruct impression_count: 0, click_count: 0, click_rate: 0.0, distribution_amount: 0.0
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
    click_count = click_count_for_last_thirty_days()

    click_rate =
      case click_count do
        0 -> 0.0
        _ -> click_count / impression_count
      end

    %State{
      impression_count: impression_count,
      click_count: click_count,
      click_rate: click_rate,
      distribution_amount: distribution_amount_for_last_thirty_days()
    }
  end

  defp impression_count_for_last_thirty_days() do
    from(user_impression in get_last_thirty_days(),
      select: count(user_impression.id)
    )
    |> Repo.one()
  end

  defp click_count_for_last_thirty_days do
    from(user_impression in get_last_thirty_days(),
      where: not is_nil(user_impression.redirected_at),
      select: count(user_impression.id)
    )
    |> Repo.one()
  end

  defp distribution_amount_for_last_thirty_days do
    from(user_impression in get_last_thirty_days(),
      select: sum(user_impression.distribution_amount)
    )
    |> Repo.one()
  end

  defp get_last_thirty_days() do
    from(user_impression in UserImpression,
      where:
        fragment(
          "?::date between ?::date and ?::date",
          user_impression.inserted_at,
          ^start_date(),
          ^now_as_date()
        )
    )
  end

  defp start_date() do
    Timex.now() |> Timex.to_date() |> Timex.shift(days: -30) |> Timex.to_date()
  end

  defp now_as_date() do
    Timex.now() |> Timex.to_date()
  end
end
