defmodule UptimeWeb.DashboardLive do
  @moduledoc false
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
      socket =
        assign(socket,
          view: params["view"] || "day",
          services: Uptime.list_services(enabled: true, preload_checks: true)
        )

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <.app>
      <:actions>
        <.select
          :let={select}
          id="select-single-select"
          name="option"
          phx-change="view_option"
          placeholder="Options"
        >
          <.select_trigger instance={select} class="w-[100px]" target="my-select" />
          <.select_content class="w-full" instance={select}>
            <.select_group>
              <.select_item instance={select} value="day" label="Day" />
              <.select_item instance={select} value="week" label="Week" />
              <.select_item instance={select} value="month" label="Month" />
              <.select_item instance={select} value="year" label="Year" />
            </.select_group>
          </.select_content>
        </.select>
        <%!-- TODO: hide when configuration comes from env vars, otherwise use to create new services --%>
        <.button>
          <.icon name="hero-plus" class="h-4 w-4 text-gray-400" />
        </.button>
      </:actions>

      <div class="max-w-5xl mx-auto mt-6">
        <%= for service <- @services do %>
          <.service_checks_summary
            service={service}
            window_started_at={@show_checks_since}
            window_ended_at={@show_checks_until}
            href={~p"/#{service.id}"}
          />
        <% end %>
      </div>
    </.app>
    """
  end

  def handle_event("view_option", _opts, socket) do
    # dbg(opts)

    {:noreply, socket}
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
end
