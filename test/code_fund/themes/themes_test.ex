defmodule CodeFund.ThemesTest do
  use CodeFund.DataCase
  alias CodeFund.Themes

  setup do
    template = insert(:template)
    theme = insert(:theme, template_id: template.id)
    {:ok, %{theme: theme, template: template}}
  end

  describe "themes" do
    alias CodeFund.Schema.Theme

    test "list_themes/0 returns all properties", %{theme: theme} do
      themes = insert_list(5, :theme)
      subject = Themes.list_themes() |> Enum.at(0)
      assert subject.name == theme.name
    end

    test "list_themes_for_template/0 returns all active properties", %{theme: theme, template: template} do
      insert_list(5, :theme)
      subject = Themes.list_themes_for_template(template)
      assert Enum.count(subject) == 1
      assert Enum.at(subject, 0).name == theme.name
    end
  end
end
