defmodule UptimeWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use UptimeWeb, :controller` and
  `use UptimeWeb, :live_view`.
  """
  use UptimeWeb, :html

  embed_templates "layouts/*"

  @badge_colors %{
    excellent: "#40cc11",
    great: "#94cc11",
    good: "#ccd311",
    okay: "#ccb311",
    bad: "#cc8111",
    very_bad: "#c7130a"
  }

  attr :duration, :string, required: true
  attr :uptime, :float, required: true

  def uptime_svg(assigns) do
    assigns =
      (assigns.uptime * 100)
      |> Decimal.from_float()
      |> Decimal.round(0)
      |> Decimal.to_string()
      |> then(&assign(assigns, :value, &1 <> "%"))

    assigns
    |> assign(:label_width, 70)
    |> assign(:value_width, String.length(assigns.value) * 11)
    |> assign(:color, uptime_color(assigns.uptime))
    |> assign(:label, "uptime #{assigns.duration}")
    |> status_svg()
  end

  attr :duration, :string, required: true
  attr :average_response_time, :integer, required: true

  def response_time_svg(assigns) do
    assigns = assign(assigns, :value, Integer.to_string(assigns.average_response_time) <> "ms")

    assigns
    |> assign(:label_width, 110)
    |> assign(:value_width, String.length(assigns.value) * 11)
    |> assign(:color, response_time_color(assigns.average_response_time))
    |> assign(:label, "response time #{assigns.duration}")
    |> status_svg()
  end

  attr :up, :boolean, required: true

  def health_svg(assigns) do
    assigns
    |> assign(:label_width, 48)
    |> assign(:value_width, (assigns.up && 28) || 44)
    |> assign(:color, (assigns.up && @badge_colors.excellent) || @badge_colors.very_bad)
    |> assign(:label, "health")
    |> assign(:value, (assigns.up && "up") || "down")
    |> status_svg()
  end

  attr :label_width, :integer, required: true
  attr :value_width, :integer, required: true
  attr :color, :string, required: true
  attr :label, :string, required: true
  attr :value, :string, required: true

  defp status_svg(assigns) do
    assigns =
      assigns
      |> assign(:label_x, assigns.label_width / 2)
      |> assign(:value_x, assigns.label_width + assigns.value_width / 2)
      |> assign(:width, assigns.label_width + assigns.value_width)

    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" width={@width} height="20">
      <linearGradient id="b" x2="0" y2="100%">
        <stop offset="0" stop-color="#bbb" stop-opacity=".1" />
        <stop offset="1" stop-opacity=".1" />
      </linearGradient>
      <mask id="a">
        <rect width={@width} height="20" rx="3" fill="#fff" />
      </mask>
      <g mask="url(#a)">
        <path fill="#555" d={"M0 0h#{@label_width}v20H0z"} />
        <path fill={@color} d={"M#{@label_width} 0h#{@value_width}v20H#{@label_width}z"} />
        <path fill="url(#b)" d={"M0 0h#{@width}v20H0z"} />
      </g>
      <g
        fill="#fff"
        text-anchor="middle"
        font-family="DejaVu Sans,Verdana,Geneva,sans-serif"
        font-size="11"
      >
        <text x={@label_x} y="15" fill="#010101" fill-opacity=".3">
          <% @label %>
        </text>
        <text x={@label_x} y="14">
          <% @label %>
        </text>
        <text x={@value_x} y="15" fill="#010101" fill-opacity=".3">
          <% @value %>
        </text>
        <text x={@value_x} y="14">
          <% @value %>
        </text>
      </g>
    </svg>
    """
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
