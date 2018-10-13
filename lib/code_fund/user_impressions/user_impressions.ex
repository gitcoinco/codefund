defmodule CodeFund.UserImpressions do
  @moduledoc """
  The UserImpressions context.
  """

  use CodeFundWeb, :query
  alias CodeFund.Query.UserImpression, as: Query

  def count() do
    Query.count() |> Repo.one()
  end
end
