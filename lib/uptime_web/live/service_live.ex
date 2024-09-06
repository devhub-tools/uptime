defmodule UptimeWeb.ServiceLive do
  @moduledoc """
  Service page shows checks results for a specific service.
  """
  use UptimeWeb, :live_view

  alias UptimeWeb.Utils

  @show_checks_since DateTime.add(DateTime.utc_now(), -24, :hour)
  @show_checks_until DateTime.utc_now()

  def mount(%{"slug" => slug}, _session, socket) do
    initial_limit = 50
    service = Uptime.get_service_by_slug!(slug, enabled: true, preload_checks: true, limit_checks: initial_limit)

    socket =
      assign(socket,
        page_title: service.name,
        show_checks_since: @show_checks_since,
        show_checks_until: @show_checks_until,
        slug: slug,
        service: service,
        total: initial_limit
      )

    if connected?(socket) do
      Uptime.subscribe_checks(service.id)
    end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="window-resize" phx-hook="WindowResize" class="space-y-6">
      <div class="flex flex-col sm:flex-row justify-between sm:items-center flex-wrap space-y-4 sm:space-y-0">
        <.back navigate={~p"/"} text="View all" />
        <div class="flex flex-row flex-wrap space-x-4">
          <div>
            <.link href={"/services/#{@service.slug}/uptimes/#{"7d"}/badge.svg"}>
              <.uptime_badge duration="7d" uptime={0.90} />
            </.link>
          </div>
          <div>
            <.link href={"/services/#{@service.slug}/uptimes/#{"7d"}/badge.svg"}>
              <.response_time_badge duration="7d" average_response_time={40} />
            </.link>
          </div>
          <div>
            <.link href={"/services/#{@service.slug}/uptimes/#{"7d"}/badge.svg"}>
              <.health_badge up={latest_checks_success(@service.checks)} />
            </.link>
          </div>
        </div>
      </div>
      <.service_checks_summary
        service={@service}
        window_started_at={@show_checks_since}
        window_ended_at={@show_checks_until}
        total={@total}
      />
    </div>
    """
  end

  def handle_info({Uptime.Check, %Uptime.Check{} = check}, socket) do
    service = socket.assigns.service

    checks =
      if length(service.checks) >= socket.assigns.total do
        # Keep the checks list fixed to calculated amount due to screen width contraints
        List.delete_at(service.checks, -1)
      else
        service.checks
      end

    checks = [check | checks]
    updated_service = %{service | checks: checks}
    {:noreply, assign(socket, service: updated_service)}
  end

  def handle_event("window_resize", values, socket) do
    width = Map.get(values, "width", 800)
    total = Utils.calculate_checks_limit(width)

    socket =
      socket
      |> assign(
        service:
          Uptime.get_service_by_slug!(socket.assigns.slug, enabled: true, preload_checks: true, limit_checks: total)
      )
      |> assign(:total, total)

    {:noreply, socket}
  end

  def latest_checks_success(checks) do
    unless checks == [] do
      checks |> Enum.at(0) |> Map.get(:status) == :success
    end
  end
end
