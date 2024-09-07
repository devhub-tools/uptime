defmodule UptimeWeb.ServiceLive do
  @moduledoc """
  Service page shows checks results for a specific service.
  """
  use UptimeWeb, :live_view

  import UptimeWeb.BadgeComponents

  alias Phoenix.LiveView.AsyncResult
  alias UptimeWeb.Utils

  @show_checks_since DateTime.add(DateTime.utc_now(), -24, :hour)
  @show_checks_until DateTime.utc_now()

  def mount(%{"slug" => slug}, _session, socket) do
    initial_check_limit = 50
    service = Uptime.get_service_by_slug!(slug, enabled: true, preload_checks: true, limit_checks: initial_check_limit)

    socket
    |> assign(
      page_title: service.name,
      start_date: DateTime.add(DateTime.utc_now(), -90, :day),
      end_date: DateTime.utc_now(),
      show_checks_since: @show_checks_since,
      show_checks_until: @show_checks_until,
      slug: slug,
      service: service,
      check_limit: initial_check_limit,
      chart_data: AsyncResult.loading()
    )
    |> then(fn socket ->
      if connected?(socket) do
        Uptime.subscribe_checks(service.id)
        fetch_chart_data(socket)
      else
        socket
      end
    end)
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-9">
      <div class="flex flex-col sm:flex-row justify-between sm:items-center flex-wrap space-y-4 sm:space-y-0">
        <.back navigate={~p"/"} text="View all" />
        <div class="flex flex-row flex-wrap space-x-4">
          <div>
            <.link href={"/v1/badges/services/#{@service.slug}/uptimes/#{"7d"}/badge.svg"}>
              <.uptime duration="7d" uptime={0.90} />
            </.link>
          </div>
          <div>
            <.link href={"/v1/badges/services/#{@service.slug}/times/#{"7d"}/badge.svg"}>
              <.response_time duration="7d" average_response_time={170} />
            </.link>
          </div>
          <div>
            <.link href={"/v1/badges/services/#{@service.slug}/health/badge.svg"}>
              <.health up={latest_checks_success(@service.checks)} />
            </.link>
          </div>
        </div>
      </div>
      <div id="window-resize" phx-hook="WindowResize">
        <.service_checks_summary
          service={@service}
          window_started_at={@show_checks_since}
          window_ended_at={@show_checks_until}
          total={@check_limit}
        />
      </div>
      <%!-- TODO: Needs date filter inputs for start/end_date --%>
      <.async_result assign={@chart_data}>
        <:loading>
          <div class="flex items-center justify-center h-72">
            <div class="h-10 w-10">
              <.loader />
            </div>
          </div>
        </:loading>
        <div id="charts" phx-hook="Chart">
          <div class="flex h-72">
            <canvas id="service-history-chart" />
          </div>
        </div>
      </.async_result>
    </div>
    """
  end

  @doc """
  Handle new checks, keep the list fixed to a calculated amount by removing the last element.
  """
  def handle_info({Uptime.Check, %Uptime.Check{} = check}, socket) do
    %{service: %{checks: checks} = service, check_limit: check_limit} = socket.assigns
    checks = if length(checks) >= check_limit, do: List.delete_at(checks, -1), else: checks

    socket
    |> assign(service: %{service | checks: [check | checks]})
    |> noreply()
  end

  def handle_event("window_resize", values, socket) do
    check_limit = values |> Map.get("width", 800) |> Utils.calculate_checks_limit()

    service =
      Uptime.get_service_by_slug!(
        socket.assigns.slug,
        enabled: true,
        preload_checks: true,
        limit_checks: check_limit
      )

    socket
    |> assign(
      service: service,
      check_limit: check_limit
    )
    |> noreply()
  end

  def latest_checks_success(checks) do
    unless checks == [] do
      checks |> Enum.at(0) |> Map.get(:status) == :success
    end
  end

  def handle_async(:chart_data, {:ok, data}, socket) do
    socket
    |> assign(chart_data: AsyncResult.ok(socket.assigns.chart_data, data))
    |> push_event("create_chart", data)
    |> noreply()
  end

  def handle_async(:chart_data, {:exit, reason}, socket) do
    socket
    |> assign(chart_data: AsyncResult.failed(socket.assigns.chart_data, {:exit, reason}))
    |> put_flash(:error, "Failed to load chart")
    |> noreply()
  end

  defp fetch_chart_data(socket) do
    %{service: service, start_date: start_date, end_date: end_date} = socket.assigns

    start_async(socket, :chart_data, fn ->
      Uptime.service_history_chart(service, start_date, end_date)
    end)
  end
end
