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
          <%= if @check.dns_time do %>
            <p><span class="font-semibold">DNS time</span>: <%= @check.dns_time %>ms</p>
          <% end %>
          <%= if @check.connect_time do %>
            <p><span class="font-semibold">Connect time</span>: <%= @check.connect_time %>ms</p>
          <% end %>
          <%= if @check.tls_time do %>
            <p><span class="font-semibold">TLS time</span>: <%= @check.tls_time %>ms</p>
          <% end %>
          <%= if @check.first_byte_time do %>
            <p><span class="font-semibold">First byte time</span>: <%= @check.first_byte_time %>ms</p>
          <% end %>
          <%= if @check.request_time do %>
            <p><span class="font-semibold">Total time</span>: <%= @check.request_time %>ms</p>
          <% end %>
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
end
