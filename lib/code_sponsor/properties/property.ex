defmodule CodeSponsor.Properties.Property do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Properties.Property


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "properties" do
    field :description, :string
    field :name, :string
    field :property_type, :integer
    field :url, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(%Property{} = property, attrs) do
    property
    |> cast(attrs, [:name, :url, :description, :property_type])
    |> validate_required([:name, :url, :description, :property_type])
  end
end
