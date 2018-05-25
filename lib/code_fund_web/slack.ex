defmodule CodeFundWeb.SlackBot do
  require Logger
  use Slack

  @doc """
  Sends message to channel use Web api.
  """
  @spec web_send_message(String.t()) :: any
  def web_send_message(message) do
    channel = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:slack_channel]

    if channel do
      web_send_message(channel, message)
    end
  end

  @doc """
  Sends message to specified user or channel through Web api.
  """
  @spec web_send_message(String.t(), String.t()) :: any
  def web_send_message(address, message) do
    token = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:slack_token]

    if token do
      avatar = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:slack_avatar]
      bot_name = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:slack_bot_name]

      Slack.Web.Chat.post_message(address, message, %{
        icon_url: avatar,
        username: bot_name
      })
    end
  end

  def handle_connect(slack, state) do
    admin = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:slack_admin]
    web_send_message(admin, "Connected as #{slack.me.name}")
    Logger.debug(fn -> "Connected as #{slack.me.name}" end)
    {:ok, state}
  end

  def handle_event(%{type: "message"} = message, _, state) do
    Logger.debug(fn -> "Info: #{inspect(message)}" end)
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    Logger.debug(fn -> "Info: #{inspect({:message, text, channel})}" end)

    send_message(text, channel, slack)

    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}
end
