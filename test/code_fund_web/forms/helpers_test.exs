defmodule CodeFundWeb.Form.HelpersTest do
  use ExUnit.Case

  describe "add_if_role" do
    test "add_if_role?/4 runs the field function if the current_user_roles contain aspirational_roles" do
      assert CodeFundWeb.Form.Helpers.add_if_role(
               %Formex.Form{},
               ["admin", "sponsor"],
               ["admin"],
               fn _form -> true end
             )
    end

    test "add_if_role?/4 returns the unchanged if the current_user_roles don't contain aspirational_roles" do
      assert CodeFundWeb.Form.Helpers.add_if_role(
               %Formex.Form{},
               ["admin", "sponsor"],
               ["user"],
               fn form -> form end
             ) == %Formex.Form{}
    end
  end
end
