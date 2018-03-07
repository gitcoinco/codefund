defmodule CodeSponsor.Repo.Migrations.CreateImpressions do
  use Ecto.Migration

  def change do
    create table(:impressions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ip, :string, null: false
      add :is_bot, :boolean, default: false
      add :user_agent, :text
      add :browser, :string
      add :os, :string
      add :device_type, :string
      add :screen_height, :integer
      add :screen_width, :integer
      add :country, :string
      add :region, :string
      add :city, :string
      add :postal_code, :string
      add :latitude, :decimal
      add :longitude, :decimal
      add :utm_source, :string
      add :utm_medium, :string
      add :utm_term, :string
      add :utm_content, :string
      add :utm_campaign, :string
      add :sponsorship_id, references(:sponsorships, on_delete: :nothing, type: :binary_id)
      add :property_id, references(:properties, on_delete: :nothing, type: :binary_id)
      add :campaign_id, references(:campaigns, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:impressions, [:ip])
    create index(:impressions, [:sponsorship_id])
    create index(:impressions, [:property_id])
    create index(:impressions, [:campaign_id])
  end
end
