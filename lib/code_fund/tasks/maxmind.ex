defmodule Mix.Tasks.Maxmind.Setup do
  use Mix.Task

  @shortdoc "Installs a geolocation database for development"
  def run(_) do
    maxmind_url =
      System.get_env("MMDB_LOCATION") ||
        "http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz"

    "curl"
    |> System.cmd([
      "-o",
      "mmdb.tar.gz",
      maxmind_url
    ])

    files = "tar" |> System.cmd(["-tvf", "mmdb.tar.gz"])

    file_name =
      files
      |> elem(0)
      |> String.trim_trailing("\n")
      |> String.split("\n")
      |> List.last()
      |> String.split(" ")
      |> List.last()

    "tar" |> System.cmd(["-xvzf", "mmdb.tar.gz", file_name])
    "mv" |> System.cmd([file_name, "./priv/maxmind/GeoIP2-Country.mmdb"])
    "rm" |> System.cmd(["mmdb.tar.gz"])
    "rm" |> System.cmd(["-rf", file_name |> String.split("/") |> List.first()])
  end
end
