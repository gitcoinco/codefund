defmodule CodeSponsor.Schema.Property  do
  use CodeSponsorWeb, :schema_with_formex

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "properties" do
    has_many :impressions, CodeSponsor.Schema.Impression
    has_many :clicks, CodeSponsor.Schema.Click
    belongs_to :sponsorship, CodeSponsor.Schema.Sponsorship
    belongs_to :user, CodeSponsor.Schema.User

    # This is used to tranfer legacy sponsored projects to the new system
    field :legacy_id, :string

    field :description, :string
    field :name, :string
    field :property_type, :integer
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(%Property{} = property, params) do
    property
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required([:user_id, :name, :url, :property_type])
  end
end
