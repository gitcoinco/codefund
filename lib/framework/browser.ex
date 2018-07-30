defmodule Framework.Browser do
  use CodeFundWeb, :controller

  def details(conn) do
    ip_address = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")

    referrer =
      (conn |> get_req_header("referer") |> Enum.at(0) || "") |> URI.parse() |> Map.get(:host)

    os = conn |> Browser.platform() |> to_string

    %{
      ip: ip_address,
      browser: Browser.Ua.to_ua(conn) |> Browser.name(),
      user_agent: Browser.Ua.to_ua(conn),
      referrer: referrer,
      os: os,
      device_type: parse_device_type(conn)
    }
  end

  @spec certify_human(Plug.Conn.t()) :: :ok | {:error, :is_bot}
  def certify_human(conn) do
    case conn |> Browser.bot?() do
      false -> :ok
      true -> {:error, :is_bot}
    end
  end

  defp parse_device_type(conn) do
    cond do
      Browser.mobile?(conn) -> "mobile"
      Browser.tablet?(conn) -> "tablet"
      Browser.console?(conn) -> "console"
      Browser.known?(conn) -> "desktop"
      true -> "unknown"
    end
  end
end
