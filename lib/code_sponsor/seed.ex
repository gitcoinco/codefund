defmodule Mix.Tasks.CodeSponsor.Seed do
  use Mix.Task
  alias CodeSponsor.Properties
  import CodeSponsor.Factory

  def run(_) do
    Mix.Task.run "app.start", []
    seed(Mix.env)
  end

  def seed(:dev) do
    sponsor     = insert(:user, %{email: "sponsor@example.com", first_name: "Gilroy", last_name: "Greene"})
    developer   = insert(:user, %{email: "developer@example.com", first_name: "Alberta", last_name: "Lemon"})
    campaign    = insert(:campaign, %{user: sponsor})
    property    = insert(:property, %{user: developer})
    sponsorship = insert(:sponsorship, %{campaign: campaign, property: property})

    # Assign sponsorship to property
    case Properties.update_property(property, %{"sponsorship_id" => sponsorship.id}) do
      {:ok, property} -> IO.puts("DONE! Property ID is #{property.id} with sponsorship id of #{property.sponsorship_id}")
      {:error, _changeset} -> IO.puts("OOPS! Seed failed!")
    end
  end

  def seed(:prod) do
    # Proceed with caution for production
  end
end