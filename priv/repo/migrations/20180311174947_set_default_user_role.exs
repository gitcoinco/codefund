defmodule CodeSponsor.Repo.Migrations.SetDefaultUserRole do
  use Ecto.Migration

  def change do
    alter table("users") do
      modify :roles, {:array, :string}, default: fragment("ARRAY['developer']")
    end
  end
end
