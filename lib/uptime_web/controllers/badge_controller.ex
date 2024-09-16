defmodule UptimeWeb.BadgeController do
  use UptimeWeb, :controller

  alias UptimeWeb.BadgeComponents

  plug :accepts, ~w(html)
  plug :put_view, html: BadgeComponents

  def uptime(conn, %{"slug" => _slug, "duration" => duration}) do
    # TODO: Get uptime value from the service
    # service = Storage.get_service!(slug: slug)

    conn
    |> assign(:type, :uptime)
    |> assign(:uptime, 0.90)
    |> assign(:duration, duration)
    |> svg()
  end

  def response_time(conn, %{"slug" => _slug, "duration" => duration}) do
    conn
    |> assign(:type, :latency)
    |> assign(:average_response_time, 170)
    |> assign(:duration, duration)
    |> svg()
  end

  def health(conn, %{"slug" => _slug}) do
    conn
    |> assign(:type, :health)
    |> assign(:up, true)
    |> svg()
  end

  defp svg(%Plug.Conn{} = conn) do
    conn
    |> put_resp_content_type("image/svg+xml")
    |> put_root_layout(false)
    |> render(:badge, layout: false)
  end
end
