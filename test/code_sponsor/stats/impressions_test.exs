defmodule CodeSponsor.Stats.ImpressionsTest do
  use CodeSponsor.DataCase

  alias CodeSponsor.Stats.Impressions
  describe "Impressions" do
    test "count/2 returns a count" do
      impression = insert(:impression)
      date = NaiveDateTime.to_date(impression.inserted_at)
      saved_impressions = Impressions.count(date, date)
      assert saved_impressions == 1
    end

    test "count/3 property returns a count" do
      impression = insert(:impression)
      property = impression.property
      date = NaiveDateTime.to_date(impression.inserted_at)
      saved_impressions = Impressions.count(property, date, date)
      assert saved_impressions == 1
    end

    test "count/3 sponsorship returns a count" do
      impression = insert(:impression)
      property = impression.sponsorship
      date = NaiveDateTime.to_date(impression.inserted_at)
      saved_impressions = Impressions.count(property, date, date)
      assert saved_impressions == 1
    end

    test "count/3 campaign returns a count" do
      impression = insert(:impression)
      property = impression.campaign
      date = NaiveDateTime.to_date(impression.inserted_at)
      saved_impressions = Impressions.count(property, date, date)
      assert saved_impressions == 1
    end

    test "count/3 user returns a count" do
      impression = insert(:impression)
      user = impression.property.user
      date = NaiveDateTime.to_date(impression.inserted_at)
      saved_impressions = Impressions.count(user, date, date)
      assert saved_impressions == 1
    end

    test "count_by_day/2 returns a count" do
      impression = insert(:impression)
      date = NaiveDateTime.to_date(impression.inserted_at)
      string_date = Date.to_string(date)
      %{^string_date => 1 } = Impressions.count_by_day(date, date)
    end

    test "count_by_day/2 property returns a count" do
      impression = insert(:impression)
      property = impression.property
      date = NaiveDateTime.to_date(impression.inserted_at)
      string_date = Date.to_string(date)
      %{^string_date => 1 } = Impressions.count_by_day(property, date, date)
    end

    test "count_by_day/2 sponsorship returns a count" do
      impression = insert(:impression)
      sponsorship = impression.sponsorship
      date = NaiveDateTime.to_date(impression.inserted_at)
      string_date = Date.to_string(date)
      %{^string_date => 1 } = Impressions.count_by_day(sponsorship, date, date)
    end

    test "count_by_day/2 campaign returns a count" do
      impression = insert(:impression)
      campaign = impression.campaign
      date = NaiveDateTime.to_date(impression.inserted_at)
      string_date = Date.to_string(date)
      %{^string_date => 1 } = Impressions.count_by_day(campaign, date, date)
    end

    test "count_by_day/2 user returns a count" do
      impression = insert(:impression)
      user = impression.property.user
      date = NaiveDateTime.to_date(impression.inserted_at)
      string_date = Date.to_string(date)
      %{^string_date => 1 } = Impressions.count_by_day(user, date, date)
    end


  end
end
