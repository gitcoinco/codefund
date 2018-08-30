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
      user: build(:user),
      slug: UUID.uuid4(),
      language: "English",
      programming_languages: ["Ruby"],
      topic_categories: ["Frontend Frameworks & Tools"],
      estimated_monthly_page_views: 50000,
      estimated_monthly_visitors: 12500
    }
  end

  def campaign_factory do
    %CodeFund.Schema.Campaign{
      name: "Test Campaign",
      redirect_url: sequence(:redirect_url, &"https://example.com/#{&1}"),
      status: 2,
      creative: build(:creative),
      ecpm: Decimal.new(2),
      impression_count: 800_000,
      budget_daily_amount: Decimal.new(25),
      total_spend: Decimal.new(2500),
      user: build(:user)
    }
  end

  def audience_factory do
    %CodeFund.Schema.Audience{
      name: "Test Audience",
      programming_languages: ["Ruby"],
      topic_categories: ["Programming"]
    }
  end

  def creative_factory do
    %CodeFund.Schema.Creative{
      name: "Test Creative",
      headline: "Creative Headline",
      body: "This is a Test Creative",
      image_url: "http://example.com/some.png",
      user: build(:user),
      large_image_bucket: "stub",
      large_image_object: "image.jpg",
      large_image_asset: insert(:asset)
    }
  end

  def asset_factory do
    %CodeFund.Schema.Asset{
      name: "Stub Image",
      user: insert(:user),
      image_bucket: "stub",
      image_object: "image.jpg",
      image: %Plug.Upload{
        content_type: "image/jpeg",
        path: Path.expand("../../test/support/mock.jpg", __DIR__),
        filename: "mock.jpg"
      }
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
      range_start: "2018-01-01",
      range_end: "2018-01-01"
    }
  end
end
