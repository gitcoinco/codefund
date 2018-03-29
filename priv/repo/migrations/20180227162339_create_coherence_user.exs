defmodule CodeFund.Repo.Migrations.CreateCoherenceUser do
  use Ecto.Migration
  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :first_name, :string
      add :last_name, :string
      add :address_1, :string
      add :address_2, :string
      add :city, :string
      add :region, :string
      add :postal_code, :string
      add :country, :string

      add :roles, {:array, :string}

      add :revenue_rate, :decimal, precision: 3, scale: 3, null: false, default: 0.5
      
      # authenticatable
      add :password_hash, :string
      
      # recoverable
      add :reset_password_token, :string
      add :reset_password_sent_at, :utc_datetime
      
      # lockable
      add :failed_attempts, :integer, default: 0
      add :locked_at, :utc_datetime
      
      # trackable
      add :sign_in_count, :integer, default: 0
      add :current_sign_in_at, :utc_datetime
      add :last_sign_in_at, :utc_datetime
      add :current_sign_in_ip, :string
      add :last_sign_in_ip, :string
      
      # unlockable_with_token
      add :unlock_token, :string
      
      # rememberable
      add :remember_created_at, :utc_datetime
      
      timestamps()
    end
    create unique_index(:users, [:email])

  end
end
