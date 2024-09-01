defmodule UptimeWeb.AppComponents do
  @moduledoc """
  Provides app UI components.
  """
  use Phoenix.Component

  alias Uptime.Checks
  alias Uptime.Services

  @doc """
  Render the service checks for a given window.
  """
  attr :service, :map, required: true
  attr :window_started_at, :map, default: nil
  attr :window_ended_at, :map, default: nil

  def service_checks_summary(assigns) do
    assigns =
      assigns
      |> assign(:name, assigns.service.name)
      |> assign(:url_str, render_url_str(assigns.service.url))
      |> assign(:time, Services.recent_check_field(assigns.service, :request_time))
      |> assign(:checks, assigns.service.checks)

    ~H"""
    <div>
      <div class="flex flex-row items-center justify-between">
        <div class="flex flex-row items-center">
          <h2 class="text-lg font-semibol mr-2">
            <%= @name %>
          </h2>
          <p class="text-lg text-gray-500">
            <%= @url_str %>
          </p>
        </div>
        <time class="block text-lg text-gray-500">
          <%= @time %>ms
        </time>
      </div>
      <div class="flex flex-row space-x-1">
        <%= for check <- @checks do %>
          <.check_indicator check={check} ok={Checks.success?(check, @service)} />
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Render the check indicator box for a service check.
  """
  attr :check, :map, required: true
  attr :ok, :boolean, default: false

  def check_indicator(assigns) do
    ~H"""
    <div class="flex flex-row items-center">
      <div class={[
        "w-2 h-10 rounded-full",
        @ok && "bg-green-500",
        !@ok && "bg-red-500"
      ]}>
      </div>
    </div>
    """
  end

  @spec render_url_str(String.t()) :: String.t()
  defp render_url_str(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: host, path: path} when is_binary(path) -> host <> path
      %URI{host: host} -> host
      _ -> url
    end
  end

  defp render_url_str(_url), do: nil
end
