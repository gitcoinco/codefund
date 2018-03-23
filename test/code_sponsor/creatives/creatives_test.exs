 defmodule CodeSponsor.CreativesTest do
   use CodeSponsor.DataCase

   alias CodeSponsor.Creatives

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

    test "get_template!/1 returns the template with given id" do
      template = insert(:template)
      saved_template = Creatives.get_template!(template.id)
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
