defmodule CodeFundWeb.Router do
  use CodeFundWeb, :router

  if Mix.env() == :dev do
    forward("/sent_emails", Bamboo.EmailPreviewPlug)
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Coherence.Authentication.Session)
  end

  pipeline :protected do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Coherence.Authentication.Session, protected: true)
    plug(:put_layout, {CodeFundWeb.LayoutView, :admin})
  end

  pipeline :protected_partials do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:put_secure_browser_headers)
    plug(Coherence.Authentication.Session, protected: true)
    plug(:put_layout, false)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :api_protected do
    plug(CodeFundWeb.Plugs.RequireAPIAccess)
  end

  pipeline :exq do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
    plug(ExqUi.RouterPlug, namespace: "exq")
  end

  scope "/exq", ExqUi do
    pipe_through(:exq)
    forward("/", RouterPlug.Router, :index)
  end

  scope "/", CodeFundWeb do
    pipe_through(:browser)
    coherence_routes()
  end

  scope "/", CodeFundWeb do
    pipe_through(:protected)
    get("/invitations", Coherence.InvitationController, :index)
    coherence_routes(:protected)
  end

  scope "/", CodeFundWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    post("/register/:type", PageController, :deliver_form)
    get("/register/:type", PageController, :contact)
    get("/p/:impression_id/pixel.png", TrackController, :pixel)
    get("/c/:impression_id", TrackController, :click)
    get("/t/l/:property_id/logo.png", TrackController, :logo)
    get("/t/r/:campaign_id/", TrackController, :improvely_inbound)
  end

  scope "/", CodeFundWeb do
    pipe_through(:protected)

    get("/dashboard", DashboardController, :index)
    get("/publisher_dashboard", DashboardController, :publisher_dashboard)
    get("/campaigns/:id/generate_fraud_check_url", CampaignController, :generate_fraud_check_url)
    resources("/assets", AssetController)
    resources("/audiences", AudienceController)
    resources("/campaigns", CampaignController)
    resources("/clicks", ClickController)
    resources("/creatives", CreativeController)
    resources("/properties", PropertyController)
    resources("/sponsorships", SponsorshipController)
    resources("/templates", TemplateController)
    resources("/themes", ThemeController)
    get("/users/:id/masquerade", UserController, :masquerade)
    get("/users/end_masquerade", UserController, :end_masquerade)

    resources("/users", UserController, only: [:index, :show, :edit, :update]) do
      patch("/refresh_api_key", UserController, :refresh_api_key)
      patch("/revoke_api_key", UserController, :revoke_api_key)
      get("/distributions/search", User.DistributionController, :search)

      resources(
        "/distributions",
        User.DistributionController,
        only: [:index, :new, :create, :show]
      )
    end
  end

  scope "/", CodeFundWeb do
    pipe_through(:protected_partials)

    # Charts
    get("/charts/traffic_impressions", ChartController, :traffic_impressions)
  end

  scope "/", CodeFundWeb.API do
    pipe_through(:api)

    get("/scripts/:property_id/embed.js", AdServeController, :embed)
    get("/t/s/:property_id/details.json", AdServeController, :details)

    resources("/audience_metrics", AudienceMetricsController, only: [:index])
    get("/users/:user_id/creatives/index.json", User.CreativeController, :index)

    scope "/api/v1", V1 do
      pipe_through(:api_protected)

      post("/impression/:property_id", Property.ImpressionController, :create,
        as: :api_property_impression
      )
    end
  end
end
