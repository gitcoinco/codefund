defmodule Framework.Ecto.Changeset.S3 do
  import Ecto.Changeset

  @spec handle_s3_upload(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def handle_s3_upload(changeset, field) do
    changeset
    |> get_change(field)
    |> upload(changeset, field)
  end

  @spec upload(%Plug.Upload{} | nil, Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  defp upload(nil, %Ecto.Changeset{} = changeset, _field), do: changeset

  defp upload(%Plug.Upload{} = upload_plug_struct, %Ecto.Changeset{} = changeset, field) do
    case Framework.FileStorage.store(upload_plug_struct) do
      {:ok, name, bucket} ->
        changeset
        |> put_change(:"#{field}_object", name)
        |> put_change(:"#{field}_bucket", bucket)

      {:error, :invalid_file_type} ->
        changeset
        |> add_error(field, "File must be JPG, PNG or GIF.", file_format: :invalid)
    end
  end
end
