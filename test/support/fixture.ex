defmodule CodeSponsor.Support.Fixture do

  def generate(schema, attrs \\ %{})

  def generate(:campaign, attrs) do
    %CodeSponsor.Schema.Campaign{
      bid_amount: Decimal.new("42.0"),
      description: "some description",
      budget_daily_amount: Decimal.new("42.0"),
      budget_monthly_amount: Decimal.new("42.0"),
      budget_total_amount: Decimal.new("42.0"),
      name: "some name",
      redirect_url: "some redirect_url",
      status: 42,
      user_id: generate(:user).id
    } |> run!(attrs)
  end

  def generate(:impression, attrs) do
     %CodeSponsor.Schema.Impression{
      browser: "some browser",
      city: "some city",
      country: "some country",
      device_type: "some device_type",
      ip: "some ip",
      latitude: Decimal.new("456.7"),
      longitude: Decimal.new("456.7"),
      os: "some os",
      postal_code: "some postal_code",
      region: "some region",
      screen_height: 42,
      screen_width: 42,
      user_agent: "some user_agent",
      utm_campaign: "some utm_campaign",
      utm_content: "some utm_content",
      utm_medium: "some utm_medium",
      utm_source: "some utm_source",
      utm_term: "some utm_term",
      property_id: generate(:property).id
    } |> run!(attrs)
  end

  def generate(:property, attrs) do
    %CodeSponsor.Schema.Property{
      description: "some description",
      name: "some name",
      property_type: 42,
      url: "some url",
      user: generate(:user)
    } |> run!(attrs)
  end

  def generate(:sponsorship, attrs) do
    %CodeSponsor.Schema.Sponsorship{
      bid_amount: Decimal.new("1.50"),
      redirect_url: "https://gitcoin.co",
      campaign_id: generate(:campaign).id
    } |> run!(attrs)
  end

  def generate(:user, attrs) do
    %CodeSponsor.Schema.User{
      first_name: "First",
      last_name: "Last",
      email: "some#{UUID.uuid4()}@example.com",
      password: "P@ssw0rd",
      password_confirmation: "P@ssw0rd"
    } |> run!(attrs)
  end

  defp run!(object, attrs), do:  object |> Map.merge(attrs) |> CodeSponsor.Repo.insert!
end