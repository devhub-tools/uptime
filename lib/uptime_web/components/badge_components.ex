defmodule UptimeWeb.BadgeComponents do
  @moduledoc """
  Components for rendering badges in controllers _and_ live views.

  This module is used by both the `UptimeWeb.BadgeController` and the
  `UptimeWeb.ServiceLive` live view to render SVG badges for uptimes and
  response times. So it has to handle assigns from both Plug.Conn as wells as
  Phoenix.Component.
  """

  use UptimeWeb, :html

  @badge_colors %{
    excellent: "#40cc11",
    great: "#94cc11",
    good: "#ccd311",
    okay: "#ccb311",
    bad: "#cc8111",
    very_bad: "#c7130a"
  }

  @doc """
  The svg is both a view for the badge controller and can also be rendered as a component.
  """
  def badge(assigns) do
    assigns = default_assigns(assigns, assigns.type)
    id = to_string(assigns.type)

    assigns =
      assigns
      |> Map.put(:label_x, assigns.label_width / 2)
      |> Map.put(:value_x, assigns.label_width + assigns.value_width / 2)
      |> Map.put(:width, assigns.label_width + assigns.value_width)
      |> Map.put(:id, id)
      |> Map.put(:id_mask, id <> "-mask")
      |> Map.put(:id_gradient, id <> "-gradient")

    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width={@width} height="20">
      <linearGradient id={@id_gradient} x2="0" y2="100%">
        <stop offset="0" stop-color="#bbb" stop-opacity=".1" />
        <stop offset="1" stop-opacity=".1" />
      </linearGradient>
      <mask id={@id_mask}>
        <rect width={@width} height="20" rx="3" fill="#fff" />
      </mask>
      <g mask={"url(##{@id_mask})"}>
        <path fill="#555" d={"M0 0h#{@label_width}v20H0z"} />
        <path fill={@color} d={"M#{@label_width} 0h#{@value_width}v20H#{@label_width}z"} />
        <path fill={"url(##{@id_gradient})"} d={"M0 0h#{@width}v20H0z"} />
      </g>
      <g
        fill="#fff"
        text-anchor="middle"
        font-family="DejaVu Sans,Verdana,Geneva,sans-serif"
        font-size="11"
      >
        <text x={@label_x} y="15" fill="#010101" fill-opacity=".3">
          <%= @label %>
        </text>
        <text x={@label_x} y="14">
          <%= @label %>
        </text>
        <text x={@value_x} y="15" fill="#010101" fill-opacity=".3">
          <%= @value %>
        </text>
        <text x={@value_x} y="14">
          <%= @value %>
        </text>
      </g>
    </svg>
    """
  end

  defp default_assigns(assigns, :uptime) do
    value =
      (assigns[:uptime] * 100)
      |> Decimal.from_float()
      |> Decimal.round(0)
      |> Decimal.to_string()
      |> Kernel.<>("%")

    assigns
    |> Map.put(:value, value)
    |> Map.put(:label_width, 70)
    |> Map.put(:value_width, String.length(value) * 11)
    |> Map.put(:color, uptime_color(assigns[:uptime]))
    |> Map.put(:label, "uptime #{assigns[:duration]}")
  end

  defp default_assigns(assigns, :latency) do
    value = Integer.to_string(assigns[:average_response_time]) <> "ms"

    assigns
    |> Map.put(:value, value)
    |> Map.put(:label_width, 105)
    |> Map.put(:value_width, String.length(value) * 11)
    |> Map.put(:color, response_time_color(assigns[:average_response_time]))
    |> Map.put(:label, "response time #{assigns[:duration]}")
  end

  defp default_assigns(assigns, :health) do
    assigns
    |> Map.put(:label_width, 48)
    |> Map.put(:value_width, (assigns[:up] && 28) || 44)
    |> Map.put(:color, (assigns[:up] && @badge_colors.excellent) || @badge_colors.very_bad)
    |> Map.put(:label, "health")
    |> Map.put(:value, (assigns[:up] && "up") || "down")
  end

  defp uptime_color(uptime) do
    cond do
      uptime >= 0.975 -> @badge_colors.excellent
      uptime >= 0.95 -> @badge_colors.great
      uptime >= 0.9 -> @badge_colors.good
      uptime >= 0.8 -> @badge_colors.okay
      uptime >= 0.65 -> @badge_colors.bad
      true -> @badge_colors.very_bad
    end
  end

  defp response_time_color(time) do
    cond do
      time <= 100 -> @badge_colors.excellent
      time <= 200 -> @badge_colors.great
      time <= 300 -> @badge_colors.good
      time <= 400 -> @badge_colors.okay
      time <= 500 -> @badge_colors.bad
      true -> @badge_colors.very_bad
    end
  end
end
