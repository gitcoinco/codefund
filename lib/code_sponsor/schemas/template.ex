defmodule CodeSponsor.Schema.Template do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Schema.Template


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "templates" do
    has_many :themes, CodeSponsor.Schema.Theme
    field :body, :string
    field :name, :string
    field :slug, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(%Template{} = template, params) do
    template
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(~w(name body slug)a)
    |> unique_constraint(:slug)
  end
end
