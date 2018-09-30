defmodule CodeFundWeb.PageController do
  use CodeFundWeb, :controller

  alias CodeFund.{Mailer}
  alias CodeFundWeb.Email.Contact

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("index.html")
  end

  @spec advertisers(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def advertisers(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("advertisers.html")
  end

  @spec publishers(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def publishers(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("publishers.html")
  end

  @spec blog(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def blog(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("blog.html")
  end

  @spec faq(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def faq(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("faq.html")
  end

  @spec team(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def team(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("team.html")
  end

  @spec ethical_advertising(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def ethical_advertising(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("ethical_advertising.html")
  end

  @spec help(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def help(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("help.html")
  end

  def about(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("about.html")
  end

  def media_kit(conn, _params) do
    conn
    |> put_layout("home.html")
    |> render("media_kit.html")
  end

  def contact(conn, %{"type" => type}) when type in ["advertiser", "publisher"] do
    conn
    |> put_layout("home.html")
    |> render("#{type}s.html")
  end

  def contact(conn, _) do
    redirect(conn, to: page_path(conn, :index))
  end

  def deliver_form(conn, %{"type" => type, "form" => form})
      when type in ["advertiser", "publisher"] do
    Contact.email(form, type) |> Mailer.deliver_now()

    redirect_url =
        case type do
          "advertiser" ->  page_path(conn, :advertisers)
          "publisher" -> page_path(conn, :publishers)
        end

    conn
    |> put_flash(:info, "Your request was submitted successfully")
    |> redirect(to: redirect_url)
  end

  def deliver_form(conn, _) do
    redirect(conn, to: page_path(conn, :index))
  end
end
