defmodule Framework.Phoenix.Form.HelpersTest do
  use CodeFundWeb.ConnCase
  alias Framework.Phoenix.Form.Helpers, as: FormHelpers

  describe "render_fields/2" do
    test "it generates HTML for a set of inputs and a submit button" do
      fields = [
        description: [type: :text_input, label: "Description"],
        bid_amount: [type: :currency_input, label: "Bid Amount"],
        some_image: [
          type: :image_preview,
          label: "An Image",
          opts: [src: "http://example.com/logo"]
        ]
      ]

      conn = build_conn()

      Phoenix.HTML.Form.form_for(conn, property_path(conn, :create), fn f ->
        form_fields = FormHelpers.render_fields(fields, f)

        assert form_fields |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string() ==
                 "<div class=\"form-group row\"><label class=\"control-label col-sm-2\">Description</label>\
<div class=\"col-sm-10\"><div class=\"input-group\"><input class=\" form-control\" name=\"description\" type=\"text\">\
</div></div></div><div class=\"form-group row\"><label class=\"control-label col-sm-2\">Bid Amount</label>\
<div class=\"col-sm-10\"><div class=\"input-group\"><div><div class=\"input-currency\">$</div>\
<input class=\" form-control\" name=\"bid_amount\" type=\"number\"></div></div></div></div><div class=\"form-group row\">\
<label class=\"control-label col-sm-2\">An Image</label><div class=\"col-sm-10\"><div class=\"input-group\"><img src=\"http://example.com/logo\"></div></div></div><button class=\"btn btn-primary\">Submit</button>"

        form_fields
      end)
    end
  end

  describe "repo_objects_to_options/2" do
    test "returns a Keyword list of options for a form select" do
      objects = [%{id: "1234", name: "first"}, %{id: "4321", name: "last"}]

      assert FormHelpers.repo_objects_to_options(objects) == [{"first", "1234"}, {"last", "4321"}]
    end
  end

  describe "repo_objects_to_options/2 with list" do
    test "returns a Keyword list of options for a form select" do
      objects = [%{id: "1234", name: "first"}, %{id: "4321", name: "last"}]

      assert FormHelpers.repo_objects_to_options(objects, [:id, :name]) == [
               {"1234 - first", "1234"},
               {"4321 - last", "4321"}
             ]
    end
  end

  describe "rest_method/2" do
    test "returns the :patch when the form action is update" do
      assert FormHelpers.rest_method(:update) == :patch
    end

    test "returns the :post when the form action is create" do
      assert FormHelpers.rest_method(:create) == :post
    end
  end
end
