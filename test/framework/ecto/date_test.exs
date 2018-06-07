defmodule Framework.Ecto.DateTest do
  use ExUnit.Case

  describe "parse/1" do
    test "it takes a date string and returns a naivedatetime" do
      assert Framework.Ecto.Date.parse("2018-01-01") == ~N[2018-01-01 00:00:00]
    end
  end
end
