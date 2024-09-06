defmodule UptimeWeb.AppComponents do
  @moduledoc """
  Provides app UI components.
  """
  use Phoenix.Component

  import UptimeWeb.Components.Helpers
  import UptimeWeb.CoreComponents
  import UptimeWeb.FormComponents

  @doc """
  Render the service checks for a given window.
  """
  attr :service, :map, required: true
  attr :total, :integer, required: true
  attr :window_started_at, :map, default: nil
  attr :window_ended_at, :map, default: nil
  attr :navigate, :string, default: nil

  def service_checks_summary(assigns) do
    since =
      case Enum.reverse(assigns.service.checks) do
        [%{inserted_at: inserted_at} | _rest] -> inserted_at
        _checks -> nil
      end

    {until, time} =
      case assigns.service.checks do
        [%{inserted_at: inserted_at, request_time: time} | _rest] -> {inserted_at, time}
        _checks -> {nil, nil}
      end

    assigns =
      assigns
      |> assign(:name, assigns.service.name)
      |> assign(:url_str, render_url_str(assigns.service.url))
      |> assign(:time, time)
      |> assign(:since, since)
      |> assign(:until, until)
      |> assign(:checks, Enum.reverse(assigns.service.checks))

    ~H"""
    <div class="space-y-1">
      <div class="flex flex-row items-center justify-between">
        <div class="flex flex-row items-center">
          <h2 class="text-lg font-semibold mr-2">
            <%= if not is_nil(@navigate) do %>
              <.link navigate={@navigate} class="hover:underline">
                <%= @name %>
              </.link>
            <% else %>
              <%= @name %>
            <% end %>
          </h2>
          <p class="text-lg text-gray-700">
            <%= @url_str %>
          </p>
        </div>
        <time class="block text-lg text-gray-700">
          <%= @time %>ms
        </time>
      </div>
      <div class="flex flex-row">
        <%= for check <- @checks do %>
          <.check_indicator check={check} total={@total} />
        <% end %>
      </div>
      <div class="flex flex-row justify-between text-xs text-gray-500">
        <format-datetime date={@since} format="relative"></format-datetime>
        <format-datetime date={@until} format="relative"></format-datetime>
      </div>
    </div>
    """
  end

  @doc """
  Render the check indicator box for a service check.

  This expects a total so it can set a fixed width, especially when service is new and checks are filling up container.
  """
  attr :check, :map, required: true
  attr :total, :integer, required: true

  def check_indicator(assigns) do
    bar_class =
      case assigns.check.status do
        :success -> "border-2 border-success bg-success group-hover/color-bar:border-primary"
        :pending -> "border-2 border-warn bg-warn group-hover/color-bar:border-primary"
        :failure -> "border-2 border-destructive bg-destructive group-hover/color-bar:border-primary"
        _unknown -> "border-2 border-muted bg-muted group-hover/color-bar:border-primary"
      end

    card_class =
      case assigns.check.status do
        :success -> "border-success"
        :pending -> "border-warn"
        :failure -> "border-destructive"
        _unknown -> "border-muted"
      end

    assigns =
      assigns
      |> assign(:bar_class, bar_class)
      |> assign(:card_class, card_class)
      |> assign(
        :width_percent,
        100 / assigns.total
      )

    ~H"""
    <.hover_card style={"max-width:#{@width_percent}%"} class="group/color-bar px-px w-full h-12">
      <.hover_card_trigger class={Enum.join(["w-full h-full rounded-full", @bar_class], " ")} />
      <.hover_card_content class={Enum.join(["w-60", @card_class], " ")} id={unique_id()}>
        <div class="space-y-2 text-sm">
          <div class="flex items-center">
            <span class="text-xs text-muted-foreground">
              <format-datetime date={@check.inserted_at} format="datetime"></format-datetime>
            </span>
          </div>
          <p>
            <span class="font-semibold">Status code</span>: <%= @check.status_code %>
          </p>
          <p><span class="font-semibold">DNS time</span>: <%= @check.dns_time %>ms</p>
          <p><span class="font-semibold">TLS time</span>: <%= @check.tls_time %>ms</p>
          <p><span class="font-semibold">Connect time</span>: <%= @check.connect_time %>ms</p>
          <p><span class="font-semibold">First byte time</span>: <%= @check.first_byte_time %>ms</p>
          <p><span class="font-semibold">Total time</span>: <%= @check.request_time %>ms</p>
        </div>
      </.hover_card_content>
    </.hover_card>
    """
  end

  def theme_toggle(assigns) do
    ~H"""
    <.button
      id="theme-toggle"
      type="button"
      phx-update="ignore"
      phx-hook="ThemeToggle"
      variant="ghost"
    >
      <svg
        id="theme-toggle-dark-icon"
        class="w-5 h-5 text-transparent hidden"
        fill="currentColor"
        viewBox="0 0 20 20"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path>
      </svg>
      <svg
        id="theme-toggle-light-icon"
        class="w-5 h-5 text-transparent"
        fill="currentColor"
        viewBox="0 0 20 20"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z"
          fill-rule="evenodd"
          clip-rule="evenodd"
        >
        </path>
      </svg>
    </.button>
    """
  end

  @spec render_url_str(String.t()) :: String.t()
  defp render_url_str(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: host, path: path} when is_binary(path) and path != "/" -> host <> path
      %URI{host: host} -> host
      _uri -> url
    end
  end

  defp render_url_str(_url), do: nil

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

  def uptime_badge(assigns) do
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

  def response_time_badge(assigns) do
    assigns = assign(assigns, :value, Integer.to_string(assigns.average_response_time) <> "ms")

    assigns
    |> assign(:label_width, 100)
    |> assign(:value_width, String.length(assigns.value) * 11)
    |> assign(:color, response_time_color(assigns.average_response_time))
    |> assign(:label, "response time #{assigns.duration}")
    |> status_svg()
  end

  attr :up, :boolean, required: true

  def health_badge(assigns) do
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
