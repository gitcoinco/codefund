defmodule CodeSponsor.Factory do
  use ExMachina.Ecto, repo: CodeSponsor.Repo

  def user_factory do
    %CodeSponsor.Coherence.User{
      first_name: "Gilroy",
      last_name: "Greene",
      email: sequence(:email, &"user-#{&1}@example.com"),
      password_hash: "$2b$12$XgUXHTx3ipopQvWHvjkwPu0khqOmZTYWtT5TMv/PIgbiadFtwBdzi", # 'secret'
      roles: ["sponsor"]
    }
  end

  def property_factory do
    %CodeSponsor.Properties.Property{
      name: "Test Website",
      url: sequence(:url, &"https://example.com/#{&1}"),
      property_type: 1,
      user: build(:user)
    }
  end

  def campaign_factory do
    %CodeSponsor.Campaigns.Campaign{
      name: "Test Campaign",
      redirect_url: sequence(:redirect_url, &"https://example.com/#{&1}"),
      status: 1,
      bid_amount: Decimal.new(2.00),
      budget_daily_amount: Decimal.new(25.00),
      budget_monthly_amount: Decimal.new(500.00),
      budget_total_amount: Decimal.new(2500.00),
      user: build(:user)
    }
  end

  def sponsorship_factory do
    %CodeSponsor.Sponsorships.Sponsorship{
      property: build(:property),
      campaign: build(:campaign),
      bid_amount: Decimal.new(250.00)
    }
  end
end