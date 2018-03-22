# defmodule CodeSponsor.CreativesTest do
#   use CodeSponsor.DataCase

#   alias CodeSponsor.Creatives

#   describe "templates" do
#     alias CodeSponsor.Creatives.Template

#     @valid_attrs %{body: "some body", name: "some name"}
#     @update_attrs %{body: "some updated body", name: "some updated name"}
#     @invalid_attrs %{body: nil, name: nil}

#     def template_fixture(attrs \\ %{}) do
#       {:ok, template} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Creatives.create_template()

#       template
#     end

#     test "list_templates/0 returns all templates" do
#       template = template_fixture()
#       assert Creatives.list_templates() == [template]
#     end

#     test "get_template!/1 returns the template with given id" do
#       template = template_fixture()
#       assert Creatives.get_template!(template.id) == template
#     end

#     test "create_template/1 with valid data creates a template" do
#       assert {:ok, %Template{} = template} = Creatives.create_template(@valid_attrs)
#       assert template.body == "some body"
#       assert template.name == "some name"
#     end

#     test "create_template/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Creatives.create_template(@invalid_attrs)
#     end

#     test "update_template/2 with valid data updates the template" do
#       template = template_fixture()
#       assert {:ok, template} = Creatives.update_template(template, @update_attrs)
#       assert %Template{} = template
#       assert template.body == "some updated body"
#       assert template.name == "some updated name"
#     end

#     test "update_template/2 with invalid data returns error changeset" do
#       template = template_fixture()
#       assert {:error, %Ecto.Changeset{}} = Creatives.update_template(template, @invalid_attrs)
#       assert template == Creatives.get_template!(template.id)
#     end

#     test "delete_template/1 deletes the template" do
#       template = template_fixture()
#       assert {:ok, %Template{}} = Creatives.delete_template(template)
#       assert_raise Ecto.NoResultsError, fn -> Creatives.get_template!(template.id) end
#     end

#     test "change_template/1 returns a template changeset" do
#       template = template_fixture()
#       assert %Ecto.Changeset{} = Creatives.change_template(template)
#     end
#   end

#   describe "themes" do
#     alias CodeSponsor.Creatives.Theme

#     @valid_attrs %{body: "some body", name: "some name"}
#     @update_attrs %{body: "some updated body", name: "some updated name"}
#     @invalid_attrs %{body: nil, name: nil}

#     def theme_fixture(attrs \\ %{}) do
#       {:ok, theme} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Creatives.create_theme()

#       theme
#     end

#     test "list_themes/0 returns all themes" do
#       theme = theme_fixture()
#       assert Creatives.list_themes() == [theme]
#     end

#     test "get_theme!/1 returns the theme with given id" do
#       theme = theme_fixture()
#       assert Creatives.get_theme!(theme.id) == theme
#     end

#     test "create_theme/1 with valid data creates a theme" do
#       assert {:ok, %Theme{} = theme} = Creatives.create_theme(@valid_attrs)
#       assert theme.body == "some body"
#       assert theme.name == "some name"
#     end

#     test "create_theme/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Creatives.create_theme(@invalid_attrs)
#     end

#     test "update_theme/2 with valid data updates the theme" do
#       theme = theme_fixture()
#       assert {:ok, theme} = Creatives.update_theme(theme, @update_attrs)
#       assert %Theme{} = theme
#       assert theme.body == "some updated body"
#       assert theme.name == "some updated name"
#     end

#     test "update_theme/2 with invalid data returns error changeset" do
#       theme = theme_fixture()
#       assert {:error, %Ecto.Changeset{}} = Creatives.update_theme(theme, @invalid_attrs)
#       assert theme == Creatives.get_theme!(theme.id)
#     end

#     test "delete_theme/1 deletes the theme" do
#       theme = theme_fixture()
#       assert {:ok, %Theme{}} = Creatives.delete_theme(theme)
#       assert_raise Ecto.NoResultsError, fn -> Creatives.get_theme!(theme.id) end
#     end

#     test "change_theme/1 returns a theme changeset" do
#       theme = theme_fixture()
#       assert %Ecto.Changeset{} = Creatives.change_theme(theme)
#     end
#   end

#   describe "creatives" do
#     alias CodeSponsor.Creatives.Creative

#     @valid_attrs %{image_url: "some image_url", text: "some text", title: "some title"}
#     @update_attrs %{image_url: "some updated image_url", text: "some updated text", title: "some updated title"}
#     @invalid_attrs %{image_url: nil, text: nil, title: nil}

#     def creative_fixture(attrs \\ %{}) do
#       {:ok, creative} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Creatives.create_creative()

#       creative
#     end

#     test "list_creatives/0 returns all creatives" do
#       creative = creative_fixture()
#       assert Creatives.list_creatives() == [creative]
#     end

#     test "get_creative!/1 returns the creative with given id" do
#       creative = creative_fixture()
#       assert Creatives.get_creative!(creative.id) == creative
#     end

#     test "create_creative/1 with valid data creates a creative" do
#       assert {:ok, %Creative{} = creative} = Creatives.create_creative(@valid_attrs)
#       assert creative.image_url == "some image_url"
#       assert creative.text == "some text"
#       assert creative.title == "some title"
#     end

#     test "create_creative/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Creatives.create_creative(@invalid_attrs)
#     end

#     test "update_creative/2 with valid data updates the creative" do
#       creative = creative_fixture()
#       assert {:ok, creative} = Creatives.update_creative(creative, @update_attrs)
#       assert %Creative{} = creative
#       assert creative.image_url == "some updated image_url"
#       assert creative.text == "some updated text"
#       assert creative.title == "some updated title"
#     end

#     test "update_creative/2 with invalid data returns error changeset" do
#       creative = creative_fixture()
#       assert {:error, %Ecto.Changeset{}} = Creatives.update_creative(creative, @invalid_attrs)
#       assert creative == Creatives.get_creative!(creative.id)
#     end

#     test "delete_creative/1 deletes the creative" do
#       creative = creative_fixture()
#       assert {:ok, %Creative{}} = Creatives.delete_creative(creative)
#       assert_raise Ecto.NoResultsError, fn -> Creatives.get_creative!(creative.id) end
#     end

#     test "change_creative/1 returns a creative changeset" do
#       creative = creative_fixture()
#       assert %Ecto.Changeset{} = Creatives.change_creative(creative)
#     end
#   end
# end
