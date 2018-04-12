defmodule CodeFundWeb.Form.Helpers do
  @spec add_if_role(%Formex.Form{}, list, list, function) :: %Formex.Form{}
  def add_if_role(%Formex.Form{} = form, current_user_roles, aspirational_roles, field_function)
      when is_list(current_user_roles) and is_list(aspirational_roles) and
             is_function(field_function) do
    case CodeFund.Users.has_role?(current_user_roles, aspirational_roles) do
      true -> field_function.(form)
      false -> form
    end
  end
end
