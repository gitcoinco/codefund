defmodule CodeFund.ThemesTest do
  use CodeFund.DataCase
  alias CodeFund.Themes

  setup do
    user = CodeFund.Support.Fixture.generate(:user)
    template = CodeFund.Support.Fixture.generate(:template)
    theme = CodeFund.Support.Fixture.generate(:theme, template_id: template.id)
    {:ok, %{user: user, theme: theme, template: template}}
  end

  describe "themes" do
    alias CodeFund.Schema.Theme

    @valid_attrs %{
      name: "Light",
      body: "body{background:#ccc}",
      slug: "light"
    }
    @update_attrs %{
      name: "Light Theme",
      body: "body{background:#fff}",
      slug: "light-theme"
    }
    @invalid_attrs %{name: nil, body: nil, slug: nil}

    test "list_themes/0 returns all properties", %{theme: theme} do
      subject = Themes.list_themes() |> Enum.at(0)
      assert subject.name == theme.name
    end

    test "list_themes_for_template/0 returns all active properties", %{
      theme: theme,
      template: template
    } do
      CodeFund.Support.Fixture.generate(:theme, @valid_attrs)
      CodeFund.Support.Fixture.generate(:theme, @valid_attrs)
      subject = Themes.list_themes_for_template(template)
      assert Enum.count(subject) == 1
      assert Enum.at(subject, 0).name == theme.name
    end
  end
end
