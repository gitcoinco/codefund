defmodule CodeFund.TemplatesTest do
  use CodeFund.DataCase
  alias CodeFund.Templates
  import CodeFund.Factory

  describe "templates" do
    test "slug_for_property_id/2 returns default slug when property_id and requested slug are nil" do
      assert Templates.slug_for_property_id(nil, nil) == "default"
    end

    test "slug_for_property_id/2 returns requested slug when property_id is nil" do
      assert Templates.slug_for_property_id(nil, "example") == "example"
    end

    test "slug_for_property_id/2 returns default slug when property template override does not exist and requested slug is nil" do
      property = insert(:property)
      assert Templates.slug_for_property_id(property.id, nil) == "default"
    end

    test "slug_for_property_id/2 returns requested slug when property template override does not exist" do
      property = insert(:property)
      assert Templates.slug_for_property_id(property.id, "example") == "example"
    end

    test "slug_for_property_id/2 returns override slug when property when template override exists" do
      property = insert(:property, template: insert(:template, slug: "custom"))
      assert Templates.slug_for_property_id(property.id, "example") == "custom"
    end
  end
end
