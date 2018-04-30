defmodule Framework.ModuleTest do
  use ExUnit.Case

  describe "pretty/3" do
    test "it returns the module name upcased and singular" do
      assert Framework.Module.pretty("things", :upcase, :singular) == "Thing"
    end

    test "it returns the module name downcased and singular" do
      assert Framework.Module.pretty("Things", :downcase, :singular) == "thing"
    end

    test "it returns the module name upcased and plural" do
      assert Framework.Module.pretty("property", :upcase, :plural) == "Properties"
    end

    test "it returns the module name downcased and plural" do
      assert Framework.Module.pretty("Property", :downcase, :plural) == "properties"
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
end
