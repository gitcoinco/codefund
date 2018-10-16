defmodule CodeFund.Stats.UserImpressionsTest do
  use CodeFund.DataCase
  alias CodeFund.Stats.UserImpressions, as: UserImpressionStats
  alias CodeFund.Impressions
  alias CodeFund.UserImpressions
  import CodeFund.Factory

  setup do
    Process.exit(Process.whereis(UserImpressionStats), :kill)
    :timer.sleep(100)

    assert UserImpressionStats.last_thirty_days() == %UserImpressionStats.State{
             impression_count: 0,
             click_count: 0,
             click_rate: 0.0,
             paid_impression_count: 0,
             paid_click_count: 0,
             paid_click_rate: 0.0,
             distribution_amount: 0.0,
             refreshed_at: nil
           }

    redirected_at = Timex.now()
    audience = insert(:audience)
    campaign = insert(:campaign, audience: audience, user: insert(:user, company: "Company Name"))

    insert(:impression,
      campaign: campaign,
      redirected_at: redirected_at,
      country: "US",
      distribution_amount: Decimal.new("0.1"),
      revenue_amount: Decimal.new("0.2")
    )

    insert(:impression, campaign: campaign, country: "US")

    Ecto.Adapters.SQL.query!(
      CodeFund.Repo,
      "REFRESH MATERIALIZED VIEW user_impressions;",
      [],
      timeout: :infinity
    )

    :ok
  end

  test "stats update after :refresh message sent to genserver" do
    Process.send(Process.whereis(UserImpressionStats), :refresh, [])

    assert Impressions.count() == 2
    assert UserImpressions.count() == 2

    assert %UserImpressionStats.State{
             click_count: 1,
             click_rate: 0.5,
             distribution_amount: distribution_amount,
             impression_count: 2,
             refreshed_at: date
           } = UserImpressionStats.last_thirty_days()

    assert date
    assert distribution_amount == Decimal.new("0.100000000000")
  end
end
