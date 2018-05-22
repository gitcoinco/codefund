defmodule CodeFund.ThemesTest do
  use CodeFund.DataCase
  import CodeFund.Factory
  alias CodeFund.Themes

  setup do
    template = insert(:template, slug: "template")
    theme = insert(:theme, slug: "theme", template: template)
    {:ok, %{theme: theme, template: template}}
  end

  describe "themes" do
    test "list_themes/0 returns all properties", %{theme: theme} do
      insert_list(5, :theme)
      subject = Themes.list_themes() |> Enum.at(0)
      assert subject.name == theme.name
    end

    test "list_themes_for_template/0 returns all active properties", %{
      theme: theme,
      template: template
    } do
      insert_list(5, :theme)
      subject = Themes.list_themes_for_template(template)
      assert Enum.count(subject) == 1
      assert Enum.at(subject, 0).name == theme.name
    end

    test "get_template_or_theme_by_slugs/2 returns a theme and template", %{theme: theme} do
      loaded_theme = Themes.get_template_or_theme_by_slugs("theme", "template")
      assert theme == loaded_theme
    end

    test "get_template_or_theme_by_slugs/2 returns a template if no theme found" do
      stub_template = insert(:template, slug: "template with no themes", themes: [])
      loaded_template = Themes.get_template_or_theme_by_slugs("none", "template with no themes")
      assert stub_template == loaded_template
    end
  end
end
