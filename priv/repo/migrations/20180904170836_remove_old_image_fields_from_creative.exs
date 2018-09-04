defmodule CodeFund.Repo.Migrations.RemoveOldImageFieldsFromCreative do
  use Ecto.Migration

  def change do
    alter table(:creatives) do
      remove :image_url
      remove :small_image_object
      remove :small_image_bucket
      remove :large_image_object
      remove :large_image_bucket
    end
  end
end
