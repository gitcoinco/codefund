defmodule CodeFundWeb.API.AudienceMetricsControllerTest do
  use CodeFundWeb.ConnCase
  import CodeFund.Factory

  setup do
    property =
      insert(:property, %{
        programming_languages: ["Ruby", "C"],
        topic_categories: ["Programming"]
      })

    property_2 =
      insert(:property, %{
        programming_languages: ["Ruby", "C"],
        topic_categories: ["Development"]
      })

    insert(:property, %{
      programming_languages: ["C"],
      topic_categories: ["Development"]
    })

    insert(:property, %{
      programming_languages: ["Java"],
      topic_categories: ["Making de internetz"]
    })

    insert_list(10, :impression, property: property, inserted_at: Timex.now())

    insert_list(
      10,
      :impression,
      property: property,
      country: "US",
      inserted_at:
        Timex.shift(Timex.now(), months: -1) |> Timex.beginning_of_month() |> Timex.shift(days: 1)
    )

    insert_list(
      10,
      :impression,
      property: property,
      country: "CN",
      inserted_at:
        Timex.shift(Timex.now(), months: -1) |> Timex.beginning_of_month() |> Timex.shift(days: 1)
    )

    insert(
      :impression,
      property: property,
      ip: "10.20.30.40",
      country: "US",
      inserted_at:
        Timex.shift(Timex.now(), months: -1) |> Timex.beginning_of_month() |> Timex.shift(days: 1)
    )

    insert_list(
      10,
      :impression,
      property: property_2,
      inserted_at:
        Timex.shift(Timex.now(), months: -1) |> Timex.beginning_of_month() |> Timex.shift(days: 1)
    )

    {:ok, %{}}
  end

  describe "GET /" do
    test "it returns a map of the count of the properties affected by the audience", %{conn: conn} do
      conn =
        get(
          conn,
          audience_metrics_path(conn, :index, %{
            "filters" => %{
              "programming_languages" => ["Ruby"],
              "topic_categories" => ["Programming"],
              "excluded_countries" => ["CN"]
            }
          })
        )

      assert json_response(conn, 200) == %{
               "property_count" => 1,
               "impression_count" => 11,
               "unique_user_count" => 2
             }
    end

    test "it runs the query correctly without excluded countries set", %{conn: conn} do
      conn =
        get(
          conn,
          audience_metrics_path(conn, :index, %{
            "filters" => %{
              "programming_languages" => ["Ruby"],
              "topic_categories" => ["Programming"]
            }
          })
        )

      assert json_response(conn, 200) == %{
               "property_count" => 1,
               "impression_count" => 21,
               "unique_user_count" => 2
             }
    end
  end
end
