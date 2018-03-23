defmodule CodeSponsor.Stats.ClicksTest do
  use CodeSponsor.DataCase


  alias CodeSponsor.Stats.Clicks


  describe "Stats.Click" do

    test "with_sponsorship_details nil" do
      assert %{} == Clicks.with_sponsorship_details(nil, %{})
    end

    test "with_sponsorship_details" do
      sponsorship = insert(:sponsorship)
      result = Clicks.with_sponsorship_details(sponsorship, %{})
      assert result.campaign_id == sponsorship.campaign_id
    end

    test "count/3 property returns a click" do
      click = insert(:click)
      property = click.property
      date = NaiveDateTime.to_date(click.inserted_at)
      saved_clicks = Clicks.count(property, date, date)
      assert saved_clicks == 1
    end

    test "count/3 sponsorship returns a click" do
      click = insert(:click)
      property = click.sponsorship
      date = NaiveDateTime.to_date(click.inserted_at)
      saved_clicks = Clicks.count(property, date, date)
      assert saved_clicks == 1
    end

    test "count/3 campaign returns a click" do
      click = insert(:click)
      property = click.campaign
      date = NaiveDateTime.to_date(click.inserted_at)
      saved_clicks = Clicks.count(property, date, date)
      assert saved_clicks == 1
    end



    test "count/3 (user) returns a click" do
      click = insert(:click)
      user = click.campaign.user
      date = NaiveDateTime.to_date(click.inserted_at)
      saved_clicks = Clicks.count(user, date, date)
      assert saved_clicks == 1
    end
  end

  describe "count_by_day" do
    test "/2" do
      click = insert(:click)
      date = NaiveDateTime.to_date(click.inserted_at)
      s_date = Date.to_iso8601(date)
      assert %{^s_date => 1 } = Clicks.count_by_day(date, date)
    end

    test "/3 property returns a count" do
      click = insert(:click)
      property = click.property
      date = NaiveDateTime.to_date(click.inserted_at)
      s_date = Date.to_iso8601(date)
      assert %{^s_date => 1 } = Clicks.count_by_day(property, date, date)
    end

    test "/3 sponsorship returns a count" do
      click = insert(:click)
      property = click.sponsorship
      date = NaiveDateTime.to_date(click.inserted_at)
      s_date = Date.to_iso8601(date)
      assert %{^s_date => 1 } = Clicks.count_by_day(property, date, date)
    end

    test "/3 campaign returns a count" do
      click = insert(:click)
      property = click.campaign
      date = NaiveDateTime.to_date(click.inserted_at)
      s_date = Date.to_iso8601(date)
      assert %{^s_date => 1 } = Clicks.count_by_day(property, date, date)
    end

    test "/3 user returns a count" do
      click = insert(:click)
      property = click.property.user
      date = NaiveDateTime.to_date(click.inserted_at)
      s_date = Date.to_iso8601(date)
      assert %{^s_date => 1 } = Clicks.count_by_day(property, date, date)
    end
  end


  describe "Stats.Click count/2" do
    test "returns a click" do
      click = insert(:click)
      date = NaiveDateTime.to_date(click.inserted_at)
      saved_clicks = Clicks.count(date, date)
      assert saved_clicks == 1
    end

    test "returns nil if no clicks" do
      date = NaiveDateTime.to_date(NaiveDateTime.utc_now())
      saved_clicks = Clicks.count(date, date)
      assert saved_clicks == 0
    end
  end

end
