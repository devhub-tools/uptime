defmodule UptimeWeb.BadgeController do
  use UptimeWeb, :controller

  alias UptimeWeb.BadgeComponents

  plug :accepts, ~w(html)
  plug :put_view, html: BadgeComponents

  def uptime(conn, %{"slug" => _slug, "duration" => duration}) do
    # TODO: Get uptime value from the service
    # service = Storage.get_service_by_slug!(slug)

    conn
    |> assign(:uptime, 0.90)
    |> assign(:duration, duration)
    |> BadgeComponents.uptime()
    |> svg()
  end

  def response_time(conn, %{"slug" => _slug, "duration" => duration}) do
    conn
    |> assign(:average_response_time, 170)
    |> assign(:duration, duration)
    |> BadgeComponents.response_time()
    |> svg()
  end

  def health(conn, %{"slug" => _slug}) do
    conn
    |> assign(:up, true)
    |> BadgeComponents.health()
    |> svg()
  end

  defp svg(%Plug.Conn{} = conn) do
    conn
    |> put_resp_content_type("image/svg+xml")
    |> put_root_layout(false)
    |> render(:badge, layout: false)
  end
end
