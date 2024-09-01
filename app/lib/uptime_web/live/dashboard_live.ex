defmodule UptimeWeb.DashboardLive do
  @moduledoc false
  use UptimeWeb, :live_view

  alias Uptime.Services

  # Placeholder for dashboard setting
  @show_checks_since DateTime.add(DateTime.utc_now(), -24, :hour)
  @show_checks_until DateTime.utc_now()

  def render(assigns) do
    ~H"""
    <.app>
      <div class="max-w-5xl px-4 mx-auto mt-6">
        <%= for service <- Services.list(enabled: true, checks_since: @show_checks_since) do %>
          <.service_checks_summary
            service={service}
            window_started_at={@show_checks_since}
            window_ended_at={@show_checks_until}
          />
        <% end %>
      </div>
    </.app>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(show_checks_since: @show_checks_since)
      |> assign(show_checks_until: @show_checks_until)

    {:ok, socket}
  end

  def handle_params(_, _, socket), do: {:noreply, socket}
end
