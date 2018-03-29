defmodule Mix.Tasks.CodeFund.Seed do
  use Mix.Task
  import CodeFund.Factory

  def run(_) do
    Mix.Task.run "app.start", []
    seed(Mix.env)
  end

  def seed(:dev) do
    admin     = insert(:user, %{email: "admin@example.com", first_name: "Joe", last_name: "Admin", roles: ["admin", "sponsor", "developer"]})
    developer = insert(:user, %{email: "developer@example.com", first_name: "Joe", last_name: "Admin", roles: ["developer"]})
    sponsor   = insert(:user, %{email: "sponsor@example.com", first_name: "Joe", last_name: "Admin", roles: ["sponsor"]})

    insert(:campaign, %{user: admin})
    insert(:property, %{user: admin})

    insert(:property, %{user: developer, name: "Developer Website", url: "https://developerwebsite.com"})
    insert(:campaign, %{user: sponsor, name: "Sponsor Campaign"})
  end

  def seed(:test) do
  end

  def seed(:prod) do
  end
end