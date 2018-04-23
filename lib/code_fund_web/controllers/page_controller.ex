defmodule CodeFundWeb.PageController do
  use CodeFundWeb, :controller

  alias CodeFund.{Mailer, Emails}

  def index(conn, _params) do
    conn = put_layout(conn, false)

    stats = %{
      impression_count: CodeFund.Repo.aggregate(CodeFund.Schema.Impression, :count, :id),
      click_count: CodeFund.Repo.aggregate(CodeFund.Schema.Click, :count, :id),
      property_count: CodeFund.Repo.aggregate(CodeFund.Schema.Property, :count, :id),
      funding_total: 1333.25
    }

    render(conn, "index.html", stats: stats)
  end

  def advertiser(conn, _params) do
    render(conn, "advertiser.html")
  end

  def publisher(conn, _params) do
    render(conn, "publisher.html")
  end

  def deliver_contact_form(conn, params) do
    Emails.contact_form_email(params) |> Mailer.deliver_now()

    conn
    |> put_flash(:info, "Your request was submitted successfully")
    |> redirect(to: page_path(conn, :index))
  end
end
