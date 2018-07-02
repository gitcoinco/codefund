defmodule Mix.Tasks.PropertySlug.Generate do
  use Mix.Task
  import Mix.Ecto
  @repo CodeFund.Repo

  @shortdoc "generates slugs for all properties"
  def run(_) do
    ensure_repo(@repo, [])
    ensure_migrations_path(@repo)
    {:ok, _pid, _apps} = ensure_started(@repo, [])

    for property <- CodeFund.Properties.list_properties() do
      slug =
        property.name
        |> Macro.underscore()
        |> String.replace(~r/\(|\//, "_")
        |> String.replace(~r/-| |\)/, "")

      CodeFund.Schema.Property.changeset(property, %{slug: slug})

      property
      |> CodeFund.Properties.update_property(%{slug: slug})
    end
  end
end
