defmodule CodeSponsor.Creatives.Theme do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Creatives.Theme

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "themes" do
    field :body, :string
    field :name, :string
    field :slug, :string
    field :description, :string

    timestamps()
  end

  @attrs [:name, :body, :slug, :description]
  @required [:name, :body, :slug]

  @doc false
  def changeset(%Theme{} = template, attrs) do
    template
    |> cast(attrs, @attrs)
    |> validate_required(@required)
    |> unique_constraint(:slug)
  end
end
