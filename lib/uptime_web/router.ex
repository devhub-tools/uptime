defmodule UptimeWeb.Router do
  use UptimeWeb, :router

  import Plug.BasicAuth

  alias Uptime.Env

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UptimeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :basic_authn do
    plug :basic_auth,
      username: Env.get("BASIC_AUTH_USERNAME"),
      password: Env.get("BASIC_AUTH_PASSWORD")
  end

  scope "/", UptimeWeb do
    pipe_through :browser

    if Env.has_basic_auth?() do
      pipe_through :basic_authn
    end

    get "/", PageController, :home
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
end
