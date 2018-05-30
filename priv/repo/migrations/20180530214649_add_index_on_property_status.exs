defmodule CodeFund.Repo.Migrations.AddIndexOnPropertyStatus do
  use Ecto.Migration

  def change do
    create_if_not_exists index("properties", [:status])
  end
end
