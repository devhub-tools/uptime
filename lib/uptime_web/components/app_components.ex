defmodule UptimeWeb.AppComponents do
  @moduledoc """
  Provides app UI components.
  """
  use UptimeWeb, :component

  import UptimeWeb.CoreComponents

  alias Uptime.Check

  @doc """
  Render the service checks for a given window.
  """
  attr :service, :map, required: true
  attr :window_started_at, :map, default: nil
  attr :window_ended_at, :map, default: nil
  attr :href, :string, default: nil

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
      |> assign(:total_checks, length(assigns.service.checks))

    ~H"""
    <div class="space-y-1">
      <div class="flex flex-row items-center justify-between">
        <div class="flex flex-row items-center">
          <h2 class="text-lg font-semibold mr-2">
            <%= if not is_nil(@href) do %>
              <.link navigate={@href} class="hover:underline">
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
          <.check_indicator check={check} />
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
  """
  attr :check, :map, required: true

  def check_indicator(assigns) do
    assigns = assign(assigns, :success, Check.success?(assigns.check))

    ~H"""
    <.hover_card class="w-full h-12">
      <.hover_card_trigger class="px-px w-full h-full">
        <div class={[
          "w-full h-full rounded-full",
          @success && "bg-green-500",
          !@success && "bg-red-500"
        ]} />
      </.hover_card_trigger>
      <.hover_card_content class="w-60" id={unique_id()}>
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
          <p><span class="font-semibold">Connect time</span>: <%= @check.connect_time %>ms</p>
          <p><span class="font-semibold">First byte time</span>: <%= @check.first_byte_time %>ms</p>
          <p><span class="font-semibold">Total time</span>: <%= @check.request_time %>ms</p>
        </div>
      </.hover_card_content>
    </.hover_card>
    """
  end

  @spec render_url_str(String.t()) :: String.t()
  defp render_url_str(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: host, path: path} when is_binary(path) -> host <> path
      %URI{host: host} -> host
      _uri -> url
    end
  end

  defp render_url_str(_url), do: nil
end
