defmodule CodeFund.Schema.Theme do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeFund.Schema.Theme

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "themes" do
    belongs_to :template, CodeFund.Schema.Template
    field :body, :string
    field :name, :string
    field :slug, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(%Theme{} = template, params) do
    template
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(~w(name body slug)a)
    |> unique_constraint(:slug, name: :themes_slug_template_id_index)
  end
end
