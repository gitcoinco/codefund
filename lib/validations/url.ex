defmodule CodeFund.Validation.URL do
  import Ecto.Changeset

  @spec validate_url(Ecto.Changeset.t(), atom) :: Ecto.Changeset.t()
  def validate_url(%Ecto.Changeset{} = changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn _, value ->
      with %URI{host: host} when is_binary(host) <- URI.parse(value),
           {:ok, _} <- :inet.gethostbyname(Kernel.to_charlist(host)) do
        []
      else
        %URI{scheme: nil} ->
          [{field, {"is missing a scheme (e.g. https)", [validation: :format]}}]

        %URI{host: nil} ->
          [{field, {"is missing a host", [validation: :format]}}]

        {:error, _} ->
          [{field, {"invalid host", [validation: :http_connect]}}]
      end
    end)
  end
end
