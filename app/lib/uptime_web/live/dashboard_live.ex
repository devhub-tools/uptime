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
          <.icon name="hero-plus" class="h-4 w-4 flex-none" />
        </.button>
      </:actions>

      <div class="max-w-5xl px-4 mx-auto mt-6">
        <%= for service <- Services.list(enabled: true, checks_since: @show_checks_since) do %>
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

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(show_checks_since: @show_checks_since)
      |> assign(show_checks_until: @show_checks_until)

    {:ok, socket}
  end

  def handle_params(_, _, socket), do: {:noreply, socket}

  def handle_event(_, opts, socket) do
    dbg(opts)

    {:noreply, socket}
  end
end
