defmodule UptimeWeb.Controllers.BadgeSVG do
  @moduledoc """
  Render SVG badges for uptimes and response times.
  """

  use UptimeWeb, :html

  alias UptimeWeb.Layouts

  def render("uptime.svg", assigns) do
    Layouts.uptime_svg(assigns)
  end
end
