defmodule Framework.FileStorage do
  @spec store(%Plug.Upload{}) ::
          {:ok, String.t(), String.t(), integer, integer} | {:error, :invalid_file_type}
  def store(%Plug.Upload{content_type: content_type, path: path, filename: filename})
      when content_type in ["image/jpeg", "image/png", "image/gif"] do
    body =
      path
      |> File.read!()

    {_, width, height, _} = ExImageInfo.info(body)

    bucket =
      :ex_aws
      |> Application.get_env(:bucket)

    name = "#{UUID.uuid4()}_#{filename}"

    {:ok, %{body: _, headers: _, status_code: 200}} =
      bucket
      |> ExAws.S3.put_object(name, body)
      |> ExAws.request()

    {:ok, name, bucket, height, width}
  end

  def store(%Plug.Upload{}) do
    {:error, :invalid_file_type}
  end

  @spec url(String.t()) :: String.t() | nil
  def url(object) when not is_nil(object) do
    [cdn_host: cdn_host] = Application.get_env(:code_fund, Framework.FileStorage)

    %URI{
      host: cdn_host,
      scheme: "https",
      path: "/#{object}"
    }
    |> URI.to_string()
  end

  def url(_), do: nil
end
