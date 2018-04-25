defmodule CodeFundWeb.PageController do
  use CodeFundWeb, :controller

  alias CodeFund.{Mailer}
  alias CodeFundWeb.Email.Contact

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

  def contact(conn, %{"type" => type}) when type in ["advertiser", "publisher"] do
    render(conn, "#{type}.html")
  end

  def contact(conn, _) do
    redirect(conn, to: page_path(conn, :index))
  end

  def deliver_form(conn, %{"type" => type, "form" => form})
      when type in ["advertiser", "publisher"] do
    Contact.email(form, type) |> Mailer.deliver_now()

    conn
    |> put_flash(:info, "Your request was submitted successfully")
    |> redirect(to: page_path(conn, :index))
  end

  def deliver_form(conn, _) do
    redirect(conn, to: page_path(conn, :index))
  end
end
