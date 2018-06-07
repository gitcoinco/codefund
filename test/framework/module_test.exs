defmodule Framework.ModuleTest do
  use ExUnit.Case

  describe "pretty/3" do
    test "it returns the module name upcased and singular" do
      assert Framework.Module.pretty("thing_stuffs", :upcase, :singular) == "ThingStuff"
    end

    test "it returns the module name upcased and singular if already upcased" do
      assert Framework.Module.pretty("ThingStuffs", :upcase, :singular) == "ThingStuff"
    end

    test "it returns the module name downcased and singular" do
      assert Framework.Module.pretty("ThingStuffs", :downcase, :singular) == "thing_stuff"
    end

    test "it returns the module name downcased and singular if already downcased" do
      assert Framework.Module.pretty("thing_stuffs", :downcase, :singular) == "thing_stuff"
    end

    test "it returns the module name upcased and plural" do
      assert Framework.Module.pretty("property_brother", :upcase, :plural) == "PropertyBrothers"
    end

    test "it returns the module name upcased and plural if already upcased" do
      assert Framework.Module.pretty("PropertyBrother", :upcase, :plural) == "PropertyBrothers"
    end

    test "it returns the module name downcased and plural" do
      assert Framework.Module.pretty("BrotherProperty", :downcase, :plural) ==
               "brother_properties"
    end

    test "it returns the module name downcased and plural if already downcased" do
      assert Framework.Module.pretty("brother_property", :downcase, :plural) ==
               "brother_properties"
    end
  end

  describe "module_name/2" do
    test "it returns the context module name" do
      assert Framework.Module.module_name("Property", :context) == CodeFund.Properties
    end

    test "it returns the context struct name" do
      assert Framework.Module.module_name("Property", :struct_name) == CodeFund.Schema.Property
    end

    test "it returns the context struct" do
      assert Framework.Module.module_name("Property", :struct) == %CodeFund.Schema.Property{}
    end
  end

  describe "fully_qualified/1" do
    test "it returns a fully qualified module from a conn if a nested resource is present" do
      conn = %{
        private: %{
          controller_config: %Controller.Config{nested: ["User"], schema: "Distribution"}
        }
      }

      assert Framework.Module.fully_qualified(conn) == User.Distribution
    end

    test "it returns a fully qualified module from a conn if multiple nested resources are present" do
      conn = %{
        private: %{
          controller_config: %Controller.Config{
            nested: ["User", "Thingy"],
            schema: "Distribution"
          }
        }
      }

      assert Framework.Module.fully_qualified(conn) == User.Thingy.Distribution
    end

    test "it returns a fully qualified module from a conn if a nested resource is not present" do
      conn = %{private: %{controller_config: %Controller.Config{schema: "Distribution"}}}
      assert Framework.Module.fully_qualified(conn) == Distribution
    end
  end
end
