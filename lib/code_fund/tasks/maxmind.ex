defmodule Mix.Tasks.Maxmind.Setup do
  use Mix.Task

  @shortdoc "Installs a geolocation database for development"
  def run(_) do
    (System.get_env("MMDB_COUNTRY_LOCATION") ||
       "http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz")
    |> install_max_mind(:country)

    (System.get_env("MMDB_CITY_LOCATION") ||
       "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz")
    |> install_max_mind(:city)
  end

  defp install_max_mind(maxmind_url, db_type) do
    tmp_dir = System.tmp_dir()
    location_of_tarball = tmp_dir <> "/mmdb.tar.gz"

    "curl"
    |> System.cmd([
      "-o",
      location_of_tarball,
      maxmind_url
    ])

    files = "tar" |> System.cmd(["-tvf", location_of_tarball])

    file_name =
      files
      |> elem(0)
      |> String.trim_trailing("\n")
      |> String.split("\n")
      |> List.last()
      |> String.split(" ")
      |> List.last()

    "tar" |> System.cmd(["-xvzf", location_of_tarball, "-C", tmp_dir, file_name])

    "mv"
    |> System.cmd([
      tmp_dir <> "/" <> file_name,
      MaxMindInitializer.get_priv_dir(Mix.env(), db_type)
    ])

    "rm" |> System.cmd([location_of_tarball])

    "rm"
    |> System.cmd(["-rf", tmp_dir <> "/" <> (file_name |> String.split("/") |> List.first())])
  end
end
