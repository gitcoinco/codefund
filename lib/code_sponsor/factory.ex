defmodule CodeSponsor.Factory do
  use ExMachina.Ecto, repo: CodeSponsor.Repo

  def user_factory do
    %CodeSponsor.Schema.User{
      first_name: "Gilroy",
      last_name: "Greene",
      email: sequence(:email, &"user-#{&1}@example.com"),
      password_hash: "$2b$12$XgUXHTx3ipopQvWHvjkwPu0khqOmZTYWtT5TMv/PIgbiadFtwBdzi", # 'secret'
      roles: ["sponsor"],
      revenue_rate: Decimal.new(0.6)
    }
  end

  def property_factory do
    %CodeSponsor.Schema.Property {
      name: "Test Website",
      url: sequence(:url, &"https://example.com/#{&1}"),
      property_type: 1,
      user: build(:user)
    }
  end

  def campaign_factory do
    %CodeSponsor.Schema.Campaign{
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
    %CodeSponsor.Schema.Sponsorship {
      property: build(:property),
      campaign: build(:campaign),
      bid_amount: Decimal.new(250.00),
      redirect_url: sequence(:redirect_url, &"https://example.com/#{&1}"),
    }
  end

  def impression_factory do
    %CodeSponsor.Schema.Impression {
      sponsorship: build(:sponsorship),
      property: build(:property),
      campaign: build(:campaign),
      ip: "51.52.53.54",
      user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
    }
  end

  def click_factory do
    %CodeSponsor.Schema.Click{
      sponsorship: build(:sponsorship),
      property: build(:property),
      campaign: build(:campaign),
      ip: "51.52.53.54",
      revenue_amount: Decimal.new(0),
      distribution_amount: Decimal.new(0),
      user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
    }
  end

  def template_factory do
    %CodeSponsor.Schema.Template{
      name: sequence(:name, &"template-#{&1}"),
      slug: sequence(:slug, &"slug-#{&1}"),
      body: sequence(:slug, &"body-#{&1}"),
    }
  end

  def theme_factory do
    %CodeSponsor.Schema.Theme{
    template: build(:template),
    name: sequence(:name, &"theme-#{&1}"),
    body: sequence(:body, &"body-#{&1}"),
    slug: sequence(:sluf, &"themeslug-#{&1}")
  }
  end
end
