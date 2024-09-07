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

  def uptime(conn_or_assigns) do
    (get(conn_or_assigns, :uptime) * 100)
    |> Decimal.from_float()
    |> Decimal.round(0)
    |> Decimal.to_string()
    |> then(&assignp(conn_or_assigns, :value, &1 <> "%"))
    |> assignp(:label_width, 70)
    |> then(&assignp(&1, :value_width, String.length(get(&1, :value)) * 11))
    |> assignp(:color, uptime_color(get(conn_or_assigns, :uptime)))
    |> assignp(:label, "uptime #{get(conn_or_assigns, :duration)}")
    |> assignp(:id, "uptime")
    |> render_component()
  end

  def response_time(conn_or_assigns) do
    conn_or_assigns
    |> assignp(:value, Integer.to_string(get(conn_or_assigns, :average_response_time)) <> "ms")
    |> assignp(:label_width, 105)
    |> then(&assignp(&1, :value_width, String.length(get(&1, :value)) * 11))
    |> assignp(:color, response_time_color(get(conn_or_assigns, :average_response_time)))
    |> assignp(:label, "response time #{get(conn_or_assigns, :duration)}")
    |> assignp(:id, "response")
    |> render_component()
  end

  def health(conn_or_assigns) do
    conn_or_assigns
    |> assignp(:label_width, 48)
    |> assignp(:value_width, (get(conn_or_assigns, :up) && 28) || 44)
    |> assignp(:color, (get(conn_or_assigns, :up) && @badge_colors.excellent) || @badge_colors.very_bad)
    |> assignp(:label, "health")
    |> assignp(:value, (get(conn_or_assigns, :up) && "up") || "down")
    |> assignp(:id, "health")
    |> render_component()
  end

  # Render the component when running as a component, or return the conn for controller.
  defp render_component(%Plug.Conn{} = conn), do: conn
  defp render_component(%{__changed__: _changed} = assigns), do: badge(assigns)

  @doc """
  The svg is both a view for the badge controller and can also be rendered as a component.
  """
  def badge(assigns) do
    assigns =
      assigns
      |> Map.put(:label_x, assigns.label_width / 2)
      |> Map.put(:value_x, assigns.label_width + assigns.value_width / 2)
      |> Map.put(:width, assigns.label_width + assigns.value_width)
      |> Map.put(:id_mask, assigns.id <> "-mask")
      |> Map.put(:id_gradient, assigns.id <> "-gradient")

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

  defp assignp(%Plug.Conn{} = conn, key, value) do
    Plug.Conn.assign(conn, key, value)
  end

  defp assignp(%{__changed__: _changed} = assigns, key, value) do
    Phoenix.Component.assign(assigns, key, value)
  end

  defp get(%Plug.Conn{} = conn, key) do
    conn.assigns[key]
  end

  defp get(%{__changed__: _changed} = assigns, key) do
    assigns[key]
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
