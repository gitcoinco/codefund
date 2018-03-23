defmodule CodeSponsor.Coherence.Rememberable do
  @moduledoc false
  use CodeSponsorWeb, :schema

  alias Coherence.Config

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rememberables" do
    field :series_hash, :string
    field :token_hash, :string
    field :token_created_at, Timex.Ecto.DateTime
    belongs_to :user, CodeSponsor.Schema.User, type: :binary_id

    timestamps()
  end

  use Coherence.Rememberable

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  @spec changeset(Ecto.Schema.t, Map.t) :: Ecto.Changeset.t
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(~w(series_hash token_hash token_created_at user_id)a)
  end

  @doc """
  Creates a changeset for a new schema
  """
  @spec new_changeset(Map.t) :: Ecto.Changeset.t
  def new_changeset(params \\ %{}) do
    changeset %Rememberable{}, params
  end

end
