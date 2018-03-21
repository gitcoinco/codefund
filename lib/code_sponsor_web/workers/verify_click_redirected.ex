defmodule CodeSponsorWeb.VerifyClickRedirected do
  alias CodeSponsor.Clicks

  def perform(click_id) do
    click = Clicks.get_click!(click_id)

    if click.status == Schema.Click.statuses[:fraud_check] do
      no_rev_dist = %{
        revenue_amount: Decimal.new(0),
        distribution_amount: Decimal.new(0)
      }
      Clicks.set_status(click, :fraud, no_rev_dist)
    end
  end
end
