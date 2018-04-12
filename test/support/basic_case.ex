defmodule CodeFundWeb.BasicCase do
  @moduledoc """
  This module defines the test case to be used by tests
  with no inherent dependencies.
  """

  use ExUnit.CaseTemplate

  setup _tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CodeFund.Repo)
    :ok = Ecto.Adapters.SQL.Sandbox.mode(CodeFund.Repo, {:shared, self()})
  end
end
