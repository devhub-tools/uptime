defmodule Uptime.Charts do
  @moduledoc false

  alias Uptime.Storage

  @colors %{
    dns: "hsl(12 76% 61%)",
    connect: "hsl(173 58% 39%)",
    tls: "hsl(197 37% 24%)",
    first_byte: "hsl(43 74% 66%)",
    finish: "hsl(27 87% 67%)"
  }

  @spec service_history(Uptime.Service.t(), DateTime.t(), DateTime.t()) :: map()
  def service_history(service, start_date, end_date) do
    data = Storage.service_chart_history(service, start_date, end_date)

    %{
      id: "service-history-chart",
      type: "line",
      stacked: true,
      labels: Enum.map(data, & &1.week),
      datasets: [
        %{
          label: "DNS",
          data: Enum.map(data, & &1.dns_time),
          backgroundColor: @colors.dns,
          fill: true
        },
        %{
          label: "Connect",
          data: Enum.map(data, & &1.connect_time),
          backgroundColor: @colors.connect,
          fill: true
        },
        %{
          label: "TLS",
          data: Enum.map(data, & &1.tls_time),
          backgroundColor: @colors.tls,
          fill: true
        },
        %{
          label: "First Byte",
          data: Enum.map(data, & &1.first_byte_time),
          backgroundColor: @colors.first_byte,
          fill: true
        },
        %{
          label: "Finish",
          data: Enum.map(data, & &1.request_time),
          backgroundColor: @colors.finish,
          fill: true
        }
      ],
      unit: "ms"
    }
  end
end
