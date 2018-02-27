defmodule CodeSponsorWeb.Router do
  use CodeSponsorWeb, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", CodeSponsorWeb do
    pipe_through :browser
    
    get "/", PageController, :index
  end

  scope "/", CodeSponsorWeb do
    pipe_through :protected
    
    resources "/properties", PropertyController
    resources "/campaigns", CampaignController
    # resources "/sponsorships", SponsorshipController
    # resources "/clicks", ClickController
    # resources "/impressions", ImpressionController
  end

  # Other scopes may use custom stacks.
  # scope "/api", CodeSponsorWeb do
  #   pipe_through :api
  # end
end
