defmodule CodeFund.Factory do
  use ExMachina.Ecto, repo: CodeFund.Repo

  def user_factory do
    %CodeFund.Schema.User{
      first_name: "Gilroy",
      last_name: "Greene",
      email: sequence(:email, &"user-#{&1}@example.com"),
      # 'secret'
      password_hash: "$2b$12$XgUXHTx3ipopQvWHvjkwPu0khqOmZTYWtT5TMv/PIgbiadFtwBdzi",
      roles: ["sponsor"],
      revenue_rate: Decimal.new("0.600")
    }
  end

  def property_factory do
    %CodeFund.Schema.Property{
      name: "Test Website",
      url: sequence(:url, &"https://example.com/#{&1}"),
      property_type: 1,
      status: 1,
      user: build(:user)
    }
  end

  def campaign_factory do
    %CodeFund.Schema.Campaign{
      name: "Test Campaign",
      redirect_url: sequence(:redirect_url, &"https://example.com/#{&1}"),
      status: 2,
      bid_amount: Decimal.new(2),
      budget_daily_amount: Decimal.new(25),
      budget_monthly_amount: Decimal.new(500),
      budget_total_amount: Decimal.new(2500),
      user: build(:user)
    }
  end

  def audience_factory do
    %CodeFund.Schema.Audience{
      name: "Test Audience",
      programming_languages: ["Ruby"],
      user: build(:user)
    }
  end

  def sponsorship_factory do
    %CodeFund.Schema.Sponsorship{
      property: build(:property),
      campaign: build(:campaign),
      creative: build(:creative),
      bid_amount: Decimal.new(250),
      override_revenue_rate: "0.3",
      user: build(:user),
      redirect_url: sequence(:redirect_url, &"https://example.com/#{&1}")
    }
  end

  def creative_factory do
    %CodeFund.Schema.Creative{
      name: "Test Creative",
      body: "This is a Test Creative",
      image_url: "http://example.com/some.png",
      user: build(:user)
    }
  end

  def theme_factory do
    %CodeFund.Schema.Theme{
      name: "Test Theme",
      body: "This is a Test Theme",
      slug: "some html"
    }
  end

  def template_factory do
    %CodeFund.Schema.Template{
      name: "Test Theme",
      body: "This is a Test Theme",
      slug: "some html"
    }
  end

  def impression_factory do
    %CodeFund.Schema.Impression{
      sponsorship: build(:sponsorship),
      property: build(:property),
      campaign: build(:campaign),
      ip: "51.52.53.54",
      user_agent:
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
    }
  end

  def distribution_factory do
    %CodeFund.Schema.Distribution{
      amount: Decimal.new("10.00"),
      currency: "USD",
      click_range_start: "2018-01-01",
      click_range_end: "2018-01-01"
    }
  end

  def click_factory do
    %CodeFund.Schema.Click{
      sponsorship: build(:sponsorship),
      property: build(:property),
      campaign: build(:campaign),
      ip: "51.52.53.54",
      revenue_amount: Decimal.new(0),
      distribution_amount: Decimal.new(0),
      user_agent:
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
    }
  end
end
