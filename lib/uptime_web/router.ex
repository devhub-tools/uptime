defmodule UptimeWeb.Router do
  use UptimeWeb, :router

  alias Uptime.Env

  @csp_default_src "default-src 'self'"
  @csp_connect_src "connect-src 'self'"
  @csp_frame_src "frame-src 'self'"
  @csp_script_src "script-src 'self'"
  @csp_img_src "img-src data: w3.org/svg/2000 'self'"
  @csp_font_src "font-src 'self' fonts.gstatic.com"
  @csp_style_src "style-src 'self' fonts.googleapis.com"
  if Env.config_env() == :dev do
    @csp_style_src @csp_style_src <> " 'unsafe-inline'"
  end

  @csp "#{@csp_default_src}; #{@csp_connect_src}; #{@csp_frame_src}; #{@csp_script_src}; #{@csp_img_src}; #{@csp_font_src}; #{@csp_style_src}"

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UptimeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers, %{"content-security-policy" => @csp}
    plug :basic_auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1/api", UptimeWeb.Controllers do
    get "/services/:id/uptimes/:duration/badge.svg", BadgeController, :uptime
  end

  scope "/", UptimeWeb do
    pipe_through :browser

    live "/", DashboardLive, :index
    live "/:slug", ServiceLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", UptimeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:uptime, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: UptimeWeb.Telemetry
    end
  end

  defp basic_auth(conn, _opts) do
    if Env.get(:enable_basic_auth?) do
      Plug.BasicAuth.basic_auth(conn, Env.get(:basic_auth))
    else
      conn
    end
  end
end
