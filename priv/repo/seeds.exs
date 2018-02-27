# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CodeSponsor.Repo.insert!(%CodeSponsor.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


CodeSponsor.Repo.delete_all CodeSponsor.Coherence.User

CodeSponsor.Coherence.User.changeset(
  %CodeSponsor.Coherence.User{}, %{
    first_name: "Test",
    last_name: "User",
    email: "testuser@example.com",
    password: "secret",
    password_confirmation: "secret"
  })
|> CodeSponsor.Repo.insert!
|> Coherence.ControllerHelpers.confirm!