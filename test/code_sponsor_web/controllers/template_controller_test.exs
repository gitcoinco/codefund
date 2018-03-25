defmodule CodeSponsorWeb.TemplateControllerTest do
  use CodeSponsorWeb.ConnCase

  describe "Template Controller" do
    @tag :admin
    test "index should list existing templates", %{conn: conn} do
      insert_list(25, :template)
      conn = get conn, template_path(conn, :index)
      assert html_response(conn, 200) =~ "Code Sponsor | Templates"
    end

    @tag :admin
    test "new should show a new template form", %{conn: conn} do
      conn = get conn, template_path(conn, :new)
      assert html_response(conn, 200) =~ "Code Sponsor | Add Template"
    end

    @tag :admin
    test "create should save a new template", %{conn: conn} do
      params = %{
        "template" =>  %{
          "name" => "template_name",
          "body" => "template_body",
          "slug" => "template_slug"
        }
      }
      assert Repo.aggregate(CodeSponsor.Schema.Template, :count, :id) == 0
      conn = post conn, template_path(conn, :create), params
      assert html_response(conn, 302)
      assert Repo.aggregate(CodeSponsor.Schema.Template, :count, :id) == 1
    end

    @tag :admin
    test "show should show a template", %{conn: conn} do
      template = insert(:template)
      conn = get conn, template_path(conn, :show, template)
      assert html_response(conn, 200) =~ "Code Sponsor | View Template"
    end

    @tag :admin
    test "edit should open a template", %{conn: conn} do
      template = insert(:template)
      conn = get conn, template_path(conn, :edit, template)
      assert html_response(conn, 200) =~ "Code Sponsor | Edit Template"
    end

    @tag :admin
    test "deletes a template", %{conn: conn} do
      template = insert(:template)
      assert Repo.aggregate(CodeSponsor.Schema.Template, :count, :id) == 1
      conn = delete conn, template_path(conn, :delete, template)
      assert html_response(conn, 302)
      assert Repo.aggregate(CodeSponsor.Schema.Template, :count, :id) == 0
    end

    @tag :admin
    test "update should edit a saved template", %{conn: conn} do
      template = insert(:template)
      params = %{
        "template" =>  %{
          "name" => "template_name",
          "body" => "template_body",
          "slug" => "template_slug"
        }
      }
      assert Repo.aggregate(CodeSponsor.Schema.Template, :count, :id) == 1
      saved_template =  Repo.one(CodeSponsor.Schema.Template)
      assert saved_template.name == template.name
      conn = patch conn, template_path(conn, :update, template), params
      assert html_response(conn, 302)
      assert Repo.aggregate(CodeSponsor.Schema.Template, :count, :id) == 1
      updated_template =  Repo.one(CodeSponsor.Schema.Template)
      assert updated_template.name == params["template"]["name"]
    end



  end
end
