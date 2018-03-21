defmodule CodeSponsor.Creatives.Template do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Creatives.Template


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "templates" do
    has_many :themes, CodeSponsor.Creatives.Theme
    field :body, :string
    field :name, :string
    field :slug, :string
    field :description, :string

    timestamps()
  end

  @attrs [:name, :body, :slug, :description]
  @required [:name, :body, :slug]

  @doc false
  def changeset(%Template{} = template, attrs) do
    template
    |> cast(attrs, @attrs)
    |> validate_required([:name, :body])
    |> unique_constraint(:slug)
  end
end
