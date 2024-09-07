defmodule UptimeWeb.BadgeHTML do
  @moduledoc """
  Render SVG badges for uptimes and response times.
  """

  use UptimeWeb, :html

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
end
