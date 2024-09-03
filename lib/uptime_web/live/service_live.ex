defmodule UptimeWeb.ServiceLive do
  @moduledoc false
  use UptimeWeb, :live_view

  @show_checks_since DateTime.add(DateTime.utc_now(), -24, :hour)
  @show_checks_until DateTime.utc_now()

  def mount(%{"id" => id}, _session, socket) do
    service = Uptime.get_service!(id, preload_checks: true)

    socket =
      socket
      |> assign(show_checks_since: @show_checks_since)
      |> assign(show_checks_until: @show_checks_until)
      |> assign(service: service)

    if connected?(socket) do
      Uptime.subscribe_checks(service.id)
    end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto mt-6 space-y-6">
      <.service_checks_summary
        service={@service}
        window_started_at={@show_checks_since}
        window_ended_at={@show_checks_until}
      />
      <div>
        TODO: More details about the checks for this service...
      </div>
    </div>
    """
  end

  def handle_info({Uptime.Check, %Uptime.Check{} = check}, socket) do
    service = socket.assigns.service
    # Keep the checks list fixed to calculated amount due to screen width contraints
    checks = [check | List.delete_at(service.checks, -1)]
    updated_service = %{service | checks: checks}
    {:noreply, assign(socket, service: updated_service)}
  end
end

# <.select
# :let={select}
# id="select-single-select"
# name="option"
# phx-change="view_option"
# placeholder="Options"
# >
# <.select_trigger instance={select} class="w-[100px]" target="my-select" />
# <.select_content class="w-full" instance={select}>
#   <.select_group>
#     <.select_item instance={select} value="day" label="Day" />
#     <.select_item instance={select} value="week" label="Week" />
#     <.select_item instance={select} value="month" label="Month" />
#     <.select_item instance={select} value="year" label="Year" />
#   </.select_group>
# </.select_content>
# </.select>
