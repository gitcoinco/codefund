defmodule CodeSponsorWeb.BaseType do
  defmacro __using__(_) do
    quote do
      use Formex.Type
      use Formex.Ecto.Type
      use Formex.Ecto.ChangesetValidator

      def changeset_after_create_callback(changeset, form) do
        if !form.struct.id do
          changeset
          |> Ecto.Changeset.put_assoc(:user, form.opts[:user])
        else
          changeset
        end
      end
    end
  end
end