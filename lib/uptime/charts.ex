defmodule Uptime.Charts do
  @moduledoc false

  alias Uptime.Storage

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
          borderColor: "#FFA500",
          backgroundColor: "#FFD580",
          fill: true
        },
        %{
          label: "Connect",
          data: Enum.map(data, & &1.connect_time),
          borderColor: "#FF0000",
          backgroundColor: "#FF8080",
          fill: true
        },
        %{
          label: "TLS",
          data: Enum.map(data, & &1.tls_time),
          borderColor: "#0000FF",
          backgroundColor: "#8080FF",
          fill: true
        },
        %{
          label: "First Byte",
          data: Enum.map(data, & &1.first_byte_time),
          borderColor: "#008000",
          backgroundColor: "#80C080",
          fill: true
        },
        %{
          label: "Finish",
          data: Enum.map(data, & &1.request_time),
          borderColor: "#800080",
          backgroundColor: "#C080C0",
          fill: true
        }
      ],
      unit: "Latency"
    }
  end
end
