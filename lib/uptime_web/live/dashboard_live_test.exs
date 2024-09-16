defmodule UptimeWeb.DashboardLiveTest do
  use UptimeWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "LIVE /", %{conn: conn} do
    conn = get(conn, "/")

    assert html_response(conn, 200)

    assert {:ok, _view, _html} = live(conn)
  end
end
