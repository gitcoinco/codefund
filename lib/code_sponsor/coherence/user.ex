defmodule CodeSponsor.Coherence.User do
  @moduledoc false
  use Ecto.Schema
  use Formex.Ecto.Schema
  use Coherence.Schema
  
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    # has_many :developer_sponsorships, CodeSponsor.Sponsorships.Sponsorship, foreign_key: :developer_id
    # has_many :sponsor_sponsorships, CodeSponsor.Sponsorships.Sponsorship, foreign_key: :sponsor_id
    has_many :campaigns, CodeSponsor.Campaigns.Campaign
    has_many :properties, CodeSponsor.Properties.Property

    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :address_1, :string
    field :address_2, :string
    field :city, :string
    field :region, :string
    field :postal_code, :string
    field :country, :string
    field :roles, {:array, :string}
    field :revenue_rate, :decimal

    coherence_schema()

    timestamps()
  end

  @attrs [
    :email,
    :first_name,
    :last_name,
    :address_1,
    :address_2,
    :city,
    :region,
    :postal_code,
    :country,
    :roles,
    :revenue_rate
  ]

  @required [
    :email,
    :first_name,
    :last_name,
    :revenue_rate
  ]

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @attrs ++ coherence_fields())
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def changeset(model, params, :password) do
    model
    |> cast(params, ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(params)
  end
end
