defmodule Mix.Tasks.PropertySlug.Generate do
  use Mix.Task
  import Mix.Ecto
  import Ecto.Query
  import Ecto.Changeset
  @repo CodeFund.Repo

  @shortdoc "generates slugs for all properties"
  def run(_) do
    ensure_repo(@repo, [])
    ensure_migrations_path(@repo)
    {:ok, _pid, _apps} = ensure_started(@repo, [])

    if Mix.env() != :test do
      for property <- CodeFund.Properties.list_properties() do
        CodeFund.Schema.Property.changeset(property, %{slug: property.slug || "stub"})
        |> update_slug(property.name)
        |> CodeFund.Repo.update()
      end
    end
  end

  defp update_slug(changeset, name) do
    case from(p in CodeFund.Schema.Property, select: count(p.id), where: p.slug == ^slugify(name))
         |> CodeFund.Repo.one() do
      0 ->
        changeset
        |> put_change(:slug, slugify(name))

      count ->
        changeset
        |> put_change(:slug, "#{slugify(name)}_#{count + 1}")
    end
  end

  defp slugify(nil), do: UUID.uuid4()

  defp slugify(field_to_base_slug_on) do
    field_to_base_slug_on
    |> Macro.underscore()
    |> String.replace(~r/\(|\//, "_")
    |> String.replace(~r/-| |\)/, "")
  end
end
