defmodule Schema.Stub do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "stubs" do
    field(:url, :string)
  end

  def changeset(%__MODULE__{} = stub, params) do
    stub
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
  end
end

defmodule CodeFund.Validation.URLTest do
  use CodeFund.DataCase
  import CodeFund.Validation.URL

  describe "validate_url" do
    test "it validates the url" do
      changeset = Schema.Stub.changeset(%Schema.Stub{}, %{url: "http://google.com"})
      assert CodeFund.Validation.URL.validate_url(changeset, :url).valid?
    end

    test "it returns an error if there is no scheme in the url" do
      changeset =
        Schema.Stub.changeset(%Schema.Stub{}, %{url: "google.com"}) |> validate_url(:url)

      refute changeset.valid?

      assert changeset.errors == [
               url: {"is missing a scheme (e.g. https)", [validation: :format]}
             ]
    end

    test "it returns an error if there is no host in the url" do
      changeset = Schema.Stub.changeset(%Schema.Stub{}, %{url: "http://"}) |> validate_url(:url)

      refute changeset.valid?
      assert changeset.errors == [url: {"is missing a host", [validation: :format]}]
    end

    test "it returns an error if the url does not resolve" do
      changeset =
        Schema.Stub.changeset(%Schema.Stub{}, %{url: "http://somefakeurl.gov"})
        |> validate_url(:url)

      refute changeset.valid?
      assert changeset.errors == [url: {"invalid host", [validation: :http_connect]}]
    end
  end
end
