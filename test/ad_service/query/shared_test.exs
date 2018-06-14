defmodule AdService.Query.SharedTest do
  use CodeFund.DataCase

  describe "build_where_clauses_by_property_filters/2" do
    test "it builds a set of where clauses based on the filters passed in" do
      query =
        from(p in CodeFund.Schema.Property)
        |> AdService.Query.Shared.build_where_clauses_by_property_filters([
          {:programming_languages, ["Ruby"]},
          {:name, "Some Property"},
          {:client_country, "US"}
        ])

      assert query.__struct__ == Ecto.Query
      [programming_languages, name, included_countries] = query.wheres

      assert programming_languages.expr ==
               {:fragment, [],
                [
                  raw: "",
                  expr: {{:., [], [{:&, [], [0]}, :programming_languages]}, [], []},
                  raw: " && ",
                  expr: {:^, [], [0]},
                  raw: "::varchar[]"
                ]}

      assert programming_languages.op == :and
      assert programming_languages.params == [{["Ruby"], :any}]

      assert name.expr == {:==, [], [{{:., [], [{:&, [], [0]}, :name]}, [], []}, {:^, [], [0]}]}
      assert name.op == :and
      assert name.params == [{"Some Property", {0, :name}}]

      assert included_countries.expr ==
               {:in, [],
                [{:^, [], [0]}, {{:., [], [{:&, [], [1]}, :included_countries]}, [], []}]}

      assert included_countries.op == :and
      assert included_countries.params == [{"US", {:out, {1, :included_countries}}}]
    end
  end
end
