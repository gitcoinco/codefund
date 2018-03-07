defmodule CodeSponsor.Repo.Migrations.CreateClicks do
  use Ecto.Migration

  def change do
    create table(:clicks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :integer, null: false, default: 0
      add :ip, :string, null: false
      add :is_bot, :boolean, default: false
      add :is_duplicate, :boolean, default: false
      add :is_fraud, :boolean, default: false
      add :user_agent, :text
      add :referrer, :text
      add :landing_page, :text
      add :referring_domain, :string
      add :search_keyword, :string
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
      add :revenue_amount, :decimal, precision: 10, scale: 2, null: false
      add :distribution_amount, :decimal, precision: 10, scale: 2, null: false
      add :sponsorship_id, references(:sponsorships, on_delete: :nothing, type: :binary_id)
      add :property_id, references(:properties, on_delete: :nothing, type: :binary_id)
      add :campaign_id, references(:campaigns, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:clicks, [:ip])
    create index(:clicks, [:sponsorship_id])
    create index(:clicks, [:property_id])
    create index(:clicks, [:campaign_id])
  end
end
