defmodule CodeFundWeb.PageController do
  use CodeFundWeb, :controller

  alias CodeFund.{Mailer}
  alias CodeFundWeb.Email.Contact

  def index(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("index.html")
  end

  def advertisers(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("advertisers.html")
  end

  def publishers(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("publishers.html")
  end

  def blog(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("blog.html")
  end

  def faq(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("faq.html")
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
