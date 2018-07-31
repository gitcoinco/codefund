defmodule Framework.FileStorage do
  @spec store(%Plug.Upload{}) :: {:ok, String.t(), String.t()} | {:error, :invalid_file_type}
  def store(%Plug.Upload{content_type: content_type, path: path, filename: filename})
      when content_type in ["image/jpeg", "image/png", "image/gif"] do
    body =
      path
      |> File.read!()

    bucket =
      :ex_aws
      |> Application.get_env(:bucket)

    name = "#{UUID.uuid4()}_#{filename}"

    {:ok, %{body: _, headers: _, status_code: 200}} =
      bucket
      |> ExAws.S3.put_object(name, body)
      |> ExAws.request()

    {:ok, name, bucket}
  end

  def store(%Plug.Upload{}) do
    {:error, :invalid_file_type}
  end

  @spec url(String.t(), String.t()) :: String.t() | nil
  def url(bucket, object)

  def url(bucket, object) when not is_nil(bucket) and not is_nil(object) do
    %{scheme: scheme, host: host, port: port} =
      :s3
      |> ExAws.Config.new()

    %URI{
      host: host,
      scheme: scheme |> String.replace("://", ""),
      port: port,
      path: "/#{bucket}/#{object}"
    }
    |> URI.to_string()
  end

  def url(_, _), do: nil
end
