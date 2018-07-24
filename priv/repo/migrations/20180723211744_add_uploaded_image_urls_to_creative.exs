defmodule CodeFund.Repo.Migrations.AddUploadedImageDetailsToCreative do
  use Ecto.Migration

  def change do
    alter table(:creatives) do
      add :small_image_object, :string
      add :small_image_bucket, :string
      add :large_image_object, :string
      add :large_image_bucket, :string
    end
  end
end
