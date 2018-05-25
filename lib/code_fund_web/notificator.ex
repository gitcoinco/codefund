defmodule CodeFundWeb.Notificator do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: CodeFundWeb.Notificator)
  end

  def init(:ok) do
    token = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:slack_token]

    {:ok, pid} =
      if token do
        options = %{keepalive: 10000}
        Slack.Bot.start_link(CodeFundWeb.SlackBot, [], token, options)
      else
        {:ok, nil}
      end

    {:ok, [pid: pid]}
  end

  @doc """
  Sends message (to slack for now)
  """
  @spec send_message(String.t()) :: any
  def send_message(message) do
    GenServer.cast(CodeFundWeb.Notificator, {:message, message})
  end

  def handle_cast({:message, message}, pid: pid) do
    if pid do
      CodeFundWeb.SlackBot.web_send_message(message)
    end

    {:noreply, [pid: pid]}
  end
end
