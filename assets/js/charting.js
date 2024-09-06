import Chart from "chart.js/auto"

Chart.defaults.borderColor = "#1f2937"
Chart.defaults.color = "#000"

export const CreateChartHook = {
  mounted() {
    var view = this
    this.handleEvent("create_chart", data => createChart(data, view))
  },
};

const createChart = (
  { id, datasets, data, labels, unit, type, max, links = [], displayLegend = false, stacked = false },
  view
) => {
  const canvas = document.getElementById(id)

  if (canvas.chart) canvas.chart.destroy()

  const chart = new Chart(canvas, {
    type: type,
    data: {
      labels: labels,
      datasets: datasets || [
        {
          data: data,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        x: {
          ticks: { maxRotation: 0 },
          grid: { display: false },
          title: { display: true, text: unit, font: { size: 10 }, color: "#000" },
          stacked: stacked,
        },
        y: {
          ticks: { maxTicksLimit: 4 },
          max: max,
          border: {
            display: false,
          },
          stacked: stacked,
        },
      },
      plugins: {
        legend: { display: displayLegend, position: "bottom" },
      },
      onClick: (_event, elements) => {
        if (elements.length > 0) {
          const firstElement = elements[0]
          const dataIndex = firstElement.index
          const link = links[dataIndex]
          if (link) view.pushEvent("navigate", { path: link + window.location.search })
        }
      },
      onHover: (event, chartElement) => {
        event.native.target.style.cursor = chartElement[0] ? "pointer" : "default"
      },
    },
  })

  canvas.chart = chart
}
