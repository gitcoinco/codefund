defmodule CodeFundWeb.User.DistributionController do
  @module "Distribution"
  use CodeFundWeb, :controller
  use Framework.Controller

  alias CodeFund.Users
  use Framework.Controller.Stub.Definitions, [@module, [:index]]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin"])

  def search(conn, %{"user_id" => user_id}) do
    user = Users.get_user!(user_id)
    render(conn, "search.html", user: user)
  end

  def show(conn, _params) do
    conn
    |> redirect(to: user_path(conn, :index))
  end

  defstub new("Distribution") do
    before_hook(&assigns_list/2)
  end

  defstub create("Distribution") do
    before_hook(&assigns_list/2)
    |> success(&success_callback/2)
    |> error(&assigns_list/2)
  end

  defp assigns_list(_conn, %{
         "user_id" => user_id,
         "params" => %{
           "distribution" => %{
             "click_range_end" => end_date,
             "click_range_start" => start_date
           }
         }
       }) do
    user = Users.get_user!(user_id)
    clicks = CodeFund.Clicks.distribution_amount(user_id, start_date, end_date)

    [
      schema: "Distribution",
      nested: ["User"],
      action: :create,
      clicks: clicks,
      user: user,
      start_date: start_date,
      end_date: end_date,
      associations: [user_id]
    ]
  end

  defp success_callback(distribution, %{
         "user_id" => user_id,
         "params" => %{
           "distribution" => %{
             "click_range_end" => end_date,
             "click_range_start" => start_date
           }
         }
       }) do
    CodeFund.Clicks.by_user_in_date_range(user_id, start_date, end_date)
    |> CodeFund.Repo.update_all(set: [distribution_id: distribution.id])
  end
end
