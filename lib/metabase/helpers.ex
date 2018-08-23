defmodule Metabase.Helpers do
  @spec dashboard_map(%CodeFund.Schema.User{}) :: map

  def dashboard_map(%CodeFund.Schema.User{roles: ["admin" | _roles]}),
    do: %{resource: %{dashboard: dashboard_role_mapping(:admin)}, params: %{}}

  def dashboard_map(%CodeFund.Schema.User{id: id, roles: [_roles | ["sponsor"]]}),
    do: advertiser_dashboard_map(id)

  def dashboard_map(%CodeFund.Schema.User{id: id, roles: ["sponsor"]}),
    do: advertiser_dashboard_map(id)

  def dashboard_map(%CodeFund.Schema.User{} = user),
    do: user |> developer_dashboard_map

  @spec developer_dashboard_map(CodeFund.Schema.User.t()) :: %{
          params: %{user_id: any()},
          resource: %{dashboard: integer()}
        }
  def developer_dashboard_map(%CodeFund.Schema.User{id: id}),
    do: %{resource: %{dashboard: dashboard_role_mapping(:user)}, params: %{user_id: id}}

  defp advertiser_dashboard_map(user_id),
    do: %{resource: %{dashboard: dashboard_role_mapping(:sponsor)}, params: %{user_id: user_id}}

  @spec dashboard_role_mapping(atom) :: integer
  defp dashboard_role_mapping(role),
    do: Application.get_env(:code_fund, :metabase_dashboard_mappings) |> Keyword.get(role)
end
