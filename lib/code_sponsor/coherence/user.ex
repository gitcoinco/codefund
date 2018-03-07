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
    field :roles, {:array, :string}
    coherence_schema()

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:first_name, :last_name, :email] ++ coherence_fields())
    |> validate_required([:first_name, :last_name, :email])
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
