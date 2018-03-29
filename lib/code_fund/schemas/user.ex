defmodule CodeFund.Schema.User do
  @moduledoc false
  use CodeFundWeb, :schema_with_formex
  use Coherence.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    has_many(:campaigns, CodeFund.Schema.Campaign)
    has_many(:properties, CodeFund.Schema.Property)
    has_many(:creatives, CodeFund.Schema.Creative)

    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:address_1, :string)
    field(:address_2, :string)
    field(:city, :string)
    field(:region, :string)
    field(:postal_code, :string)
    field(:country, :string)
    field(:roles, {:array, :string})
    field(:revenue_rate, :decimal)

    coherence_schema()

    timestamps()
  end

  @required [
    :email,
    :first_name,
    :last_name
  ]

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, fields())
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def changeset(model, params, :password) do
    model
    |> cast(
      params,
      ~w(password password_confirmation reset_password_token reset_password_sent_at)
    )
    |> validate_coherence_password_reset(params)
  end

  defp fields(), do: (__MODULE__.__schema__(:fields) |> List.delete(:id)) ++ coherence_fields()
end
