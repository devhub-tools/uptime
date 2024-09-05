defmodule UptimeWeb.DashboardLive do
  @moduledoc """
  Dashboard page shows a summary of all services.
  """
  use UptimeWeb, :live_view

  # Placeholder for dashboard setting
  @show_checks_since DateTime.add(DateTime.utc_now(), -24, :hour)
  @show_checks_until DateTime.utc_now()

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        show_checks_since: @show_checks_since,
        show_checks_until: @show_checks_until,
        services: []
      )

    if connected?(socket) do
      Uptime.subscribe_checks()
    end

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    if connected?(socket) do
      socket = assign(socket, view: params["view"] || "day")
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div id="window-resize" phx-hook="WindowResize">
      <%= for service <- @services do %>
        <.service_checks_summary
          service={service}
          window_started_at={@show_checks_since}
          window_ended_at={@show_checks_until}
          href={~p"/#{service.id}"}
        />
      <% end %>
    </div>
    """
  end

  def handle_info({Uptime.Check, %Uptime.Check{} = check}, socket) do
    service_id = check.service_id

    case Enum.find(socket.assigns.services, fn service -> service.id == service_id end) do
      nil ->
        {:noreply, socket}

      service ->
        # Keep the checks list fixed to calculated amount due to screen width contraints
        checks = [check | List.delete_at(service.checks, -1)]
        updated_service = %{service | checks: checks}

        updated_services =
          Enum.map(socket.assigns.services, fn s -> if s.id == service_id, do: updated_service, else: s end)

        {:noreply, assign(socket, services: updated_services)}
    end
  end

  def handle_event("window_resize", values, socket) do
    width = Map.get(values, "width", 800)
    socket = assign(socket, services: list_services(calculate_checks_limit(width)))
    {:noreply, socket}
  end

  # Leaves width of color bar ~8-9px accounting for page padding and margins between bars.
  defp calculate_checks_limit(width) do
    (width / 10 - 10)
    |> Decimal.from_float()
    |> Decimal.round(0)
    |> Decimal.to_integer()
    |> max(20)
  end

  defp list_services(checks) do
    Uptime.list_services(enabled: true, preload_checks: true, limit_checks: checks)
  end
end
