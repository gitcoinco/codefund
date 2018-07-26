defmodule StubImageSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "stubs" do
    field(:image, :any, virtual: true)
    field(:image_object, :string)
    field(:image_bucket, :string)
  end

  @doc false
  def changeset(%__MODULE__{} = stub, params) do
    stub
    |> cast(params, [:image, :image_object, :image_bucket])
  end
end

defmodule Framework.Ecto.Changeset.S3Test do
  use ExUnit.Case

  describe "handle_s3_upload/2" do
    test "it casts a set of date strings to naivedatetimes" do
      changeset =
        %StubImageSchema{}
        |> StubImageSchema.changeset(%{
          image: %Plug.Upload{
            content_type: "image/jpeg",
            path: Path.expand("../../../support/mock.jpg", __DIR__),
            filename: "mock.jpg"
          }
        })
        |> Framework.Ecto.Changeset.S3.handle_s3_upload(:image)

      assert changeset.changes.image_bucket == "stub"
      assert changeset.changes.image_object =~ "mock.jpg"

      assert changeset.valid?
    end

    test "it returns an error if the file format is invalid" do
      changeset =
        %StubImageSchema{}
        |> StubImageSchema.changeset(%{
          image: %Plug.Upload{
            content_type: "application/pdf",
            path: Path.expand("../../../test/support/mock.pdf", __DIR__),
            filename: "mock.pdf"
          }
        })
        |> Framework.Ecto.Changeset.S3.handle_s3_upload(:image)

      refute changeset.changes |> Map.get(:image_bucket)
      refute changeset.changes |> Map.get(:image_object)

      assert changeset.errors == [
               image: {"File must be JPG, PNG or GIF.", [file_format: :invalid]}
             ]

      refute changeset.valid?
    end
  end
end
