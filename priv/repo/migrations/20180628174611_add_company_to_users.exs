defmodule CodeFund.Repo.Migrations.AddCompanyToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:company, :string)
    end
  end
end
