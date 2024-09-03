defmodule UptimeWeb.Controllers.BadgeController do
  use UptimeWeb, :controller

  plug :accepts, ~w(html svg)
  plug :put_view, html: UptimeWeb.Controllers.BadgeSVG

  def uptime(conn, %{"id" => _id, "duration" => duration}) do
    # TODO: Get uptime value from the service
    # service = Storage.get_service!(id)

    conn
    |> put_resp_content_type("image/svg+xml")
    |> put_root_layout(false)
    |> render(:uptime, duration: duration, uptime: 0.1)
  end
end
