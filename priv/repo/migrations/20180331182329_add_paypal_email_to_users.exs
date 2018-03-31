defmodule CodeFund.Repo.Migrations.AddPaypalEmailToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :paypal_email, :string
    end
  end
end
