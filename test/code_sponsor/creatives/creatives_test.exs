 defmodule CodeSponsor.CreativesTest do
   use CodeSponsor.DataCase

   alias CodeSponsor.Creatives
   alias CodeSponsor.Schema.Theme

   describe "themes" do
     @valid_attrs %{body: "some body", name: "some name", slug: "some slug"}
     @update_attrs %{body: "some updated body", name: "some updated name", slug: "some updated slug"}
     @invalid_attrs %{body: nil, name: nil}
     test "list_themes/0 returns all themes" do
       theme = insert(:theme)
       [first_theme | _] = Creatives.list_themes()
       assert first_theme.id == theme.id
     end

     test "get_theme/1 returns all themes" do
       theme = insert(:theme)
       saved_theme = Creatives.get_theme!(theme.id)
       assert saved_theme.id == theme.id
     end

     test "get_theme_by_slug returns all themes" do
       theme = insert(:theme)
       saved_theme = Creatives.get_theme_by_slug!(theme.slug)
       assert saved_theme.id == theme.id
     end

     test "paginate_themes/1 returns 15 themes" do
       theme = insert_list(25, :theme)
       {:ok, %{themes: themes}} = Creatives.paginate_themes(%{})
       assert Enum.count(themes) == 15
     end

     test "create_theme/1 with valid data creates a template" do
       assert {:ok, %Theme{} = theme} = Creatives.create_theme(@valid_attrs)
       assert theme.body == "some body"
       assert theme.name == "some name"
     end

     test "update_theme/2 with valid data updates the template" do
       theme = insert(:theme)
       assert {:ok, theme} = Creatives.update_theme(theme, @update_attrs)
       assert %Theme{} = theme
       assert theme.body == "some updated body"
       assert theme.name == "some updated name"
     end

     test "change_theme/1 returns a changeset" do
       theme = insert(:theme)
       theme = Creatives.change_theme(theme)
       assert %Ecto.Changeset{} = theme
     end

     test "delete_theme/1 with valid data updates the template" do
       theme = insert(:theme)
       Creatives.delete_theme(theme)
       assert Repo.aggregate(Theme, :count, :id) == 0
     end
   end

   describe "creatives" do
     alias CodeSponsor.Schema.Creative
     alias CodeSponsor.Creatives

     @valid_attrs %{image_url: "some image_url", name: "some text", body: "some title"}
     @update_attrs %{image_url: "some updated image_url", name: "some updated text", body: "some updated title"}
     @invalid_attrs %{image_url: nil, text: nil, title: nil}

     test "list_creatives/0 returns all creatives" do
      insert_list(25, :creative)
      saved_creatives =  Creatives.list_creatives()
      assert Enum.count(saved_creatives) == 25
     end

     test "paginate_creatives/1 returns all creatives" do
      insert_list(25, :creative)
      {:ok, %{creatives: paginated_creatives}} =  Creatives.paginate_creatives(%{})
      assert Enum.count(paginated_creatives) == 15
     end

    test "get_creative!/1 returns the creative with given id" do
      creative = insert(:creative)
      saved_creative = Creatives.get_creative!(creative.id)
      assert creative.id == saved_creative.id
    end

    test "create_creative/1 with valid data creates a creative" do
      assert {:ok, %Creative{} = creative} = Creatives.create_creative(@valid_attrs)
      assert creative.image_url == "some image_url"
      assert creative.name == "some text"
      assert creative.body == "some title"
    end

    test "create_creative/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Creatives.create_creative(@invalid_attrs)
    end

    test "update_creative/2 with valid data updates the creative" do
      creative = insert(:creative)
      {:ok, creative}  = Creatives.update_creative(creative, @update_attrs)
      assert %Creative{} = creative
      assert creative.image_url == "some updated image_url"
      assert creative.name == "some updated text"
      assert creative.body == "some updated title"
    end

    test "update_creative/2 with invalid data returns error changeset" do
      creative = insert(:creative)
      assert {:error, %Ecto.Changeset{}} = Creatives.update_creative(creative, @invalid_attrs)
      saved_creative = Creatives.get_creative!(creative.id)
      assert creative.id == saved_creative.id
    end

    test "delete_creative/1 deletes the creative" do
      creative = insert(:creative)
      assert {:ok, %Creative{}} = Creatives.delete_creative(creative)
      assert_raise Ecto.NoResultsError, fn -> Creatives.get_creative!(creative.id) end
    end

    test "change_creative/1 returns a creative changeset" do
      creative = insert(:creative)
      assert %Ecto.Changeset{} = Creatives.change_creative(creative)
    end
   end

   describe "templates" do
     alias CodeSponsor.Schema.Template

     @valid_attrs %{body: "some body", name: "some name", slug: "some slug"}
     @update_attrs %{body: "some updated body", name: "some updated name", slug: "some updated slug"}
     @invalid_attrs %{body: nil, name: nil}



     test "list_templates/0 returns all templates" do
       template = insert(:template)
       [first_template | _] = Creatives.list_templates()
       assert first_template.id == template.id
     end

     test "paginate_templates/1 returns all templates" do
       insert_list(25, :template)
       {:ok, %{templates: saved_templates}} = Creatives.paginate_templates(%{})
       assert Enum.count(saved_templates) == 15
     end

    test "get_template!/1 returns the template with given id" do
      template = insert(:template)
      saved_template = Creatives.get_template!(template.id)
      assert saved_template.id == template.id
    end

    test "get_template_by_slug/1 returns the template with given id" do
      template = insert(:template)
      saved_template = Creatives.get_template_by_slug(template.slug)
      assert saved_template.id == template.id
    end

    test "create_template/1 with valid data creates a template" do
      assert {:ok, %Template{} = template} = Creatives.create_template(@valid_attrs)
      assert template.body == "some body"
      assert template.name == "some name"
    end

    test "create_template/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Creatives.create_template(@invalid_attrs)
    end

    test "update_template/2 with valid data updates the template" do
      template = insert(:template)
      assert {:ok, template} = Creatives.update_template(template, @update_attrs)
      assert %Template{} = template
      assert template.body == "some updated body"
      assert template.name == "some updated name"
    end

    test "update_template/2 with invalid data returns error changeset" do
      template = insert(:template)
      assert {:error, %Ecto.Changeset{}} = Creatives.update_template(template, @invalid_attrs)
      assert template == Creatives.get_template!(template.id)
    end

    test "delete_template/1 deletes the template" do
      template = insert(:template)
      assert {:ok, %Template{}} = Creatives.delete_template(template)
      assert_raise Ecto.NoResultsError, fn -> Creatives.get_template!(template.id) end
    end

    test "change_template/1 returns a template changeset" do
      template = insert(:template)
      assert %Ecto.Changeset{} = Creatives.change_template(template)
    end
  end
 end
