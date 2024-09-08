import { type Hook } from "./helpers";
import Chart from "chart.js/auto";
import type {
  ChartEvent,
  ActiveElement,
  ChartDataset,
  ChartType,
} from "chart.js";

Chart.defaults.borderColor = "#1f2937";
Chart.defaults.color = "#000";

type ChartJSHook = {
  id?: string;
  destroyIfPresent(): void;
  createChart(canvas: HTMLCanvasElement, options: Options): Chart | undefined;
} & Hook;

type Options = {
  id: string;
  datasets?: ChartDataset[];
  type: ChartType;
  displayLegend: boolean;
  stacked: boolean;
  labels: string[];
  unit: string;
  max: number;
  // Is data needed?
  data: any;
  links: string[];
};

type ChartCanvas = HTMLCanvasElement & { chart?: Chart };

const getBodyColor = () => {
  const body = document.querySelector("body");
  if (body instanceof HTMLElement) {
    return window.getComputedStyle(body).color;
  }
  return "#000";
};

const isCanvas = (el: HTMLElement | null): el is HTMLCanvasElement =>
  el instanceof HTMLCanvasElement;
const hasChart = (canvas: HTMLElement | null): canvas is ChartCanvas =>
  !!canvas && "chart" in canvas && !!canvas.chart;
const isChart = (chart: unknown): chart is Chart => chart instanceof Chart;

export const ChartHook: ChartJSHook = {
  mounted() {
    if (this.handleEvent) {
      this.handleEvent("create_chart", (payload: unknown) => {
        const data = payload as Options;
        const canvas = document.getElementById(data.id);
        if (isCanvas(canvas)) {
          this.id = data.id;
          this.destroyIfPresent();
          const c = canvas as ChartCanvas;
          c.chart = this.createChart(canvas, data);
          // update axis colors on theme change
          const themeToggle = document.getElementById("theme-toggle");
          if (themeToggle instanceof HTMLButtonElement) {
            themeToggle.addEventListener("click", () => {
              if (c.chart?.options.scales?.y?.ticks) {
                c.chart.options.scales.y.ticks.color = getBodyColor();
                c.chart?.update();
              }
            });
          }
        }
      });
    }
  },
  destroyed() {
    this.destroyIfPresent();
  },
  destroyIfPresent() {
    const canvas = this.id ? document.getElementById(this.id) : null;
    if (isCanvas(canvas) && hasChart(canvas) && isChart(canvas.chart)) {
      canvas.chart.destroy();
    }
  },
  createChart(canvas: HTMLCanvasElement, options: Options) {
    const {
      id,
      datasets,
      data,
      labels,
      unit,
      type,
      max,
      links = [],
      displayLegend = false,
      stacked = false,
    } = options;
    return new Chart(canvas, {
      type,
      data: {
        labels,
        datasets: datasets || [
          {
            data,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          x: {
            ticks: {
              display: false,
            },
            border: {
              display: true,
              color: "hsl(25 5.3% 44.7%)",
            },
            stacked,
          },
          y: {
            ticks: {
              maxTicksLimit: 3,
              callback: (value, _index, _ticks) => value + unit,
              color: getBodyColor(),
              font: {
                size: 11,
              },
            },
            max,
            grid: {
              display: false,
            },
            border: {
              display: true,
              color: "hsl(25 5.3% 44.7%)",
            },
            stacked,
          },
        },
        plugins: {
          legend: { display: displayLegend, position: "bottom" },
        },
        onClick: (_event: ChartEvent, elements: ActiveElement[]) => {
          if (elements.length > 0) {
            const firstElement = elements[0];
            const dataIndex = firstElement.index;
            const link = links[dataIndex];
            if (link && this.pushEvent)
              this.pushEvent("navigate", {
                path: link + window.location.search,
              });
          }
        },
        onHover: (event: ChartEvent, elements: ActiveElement[]) => {
          const target = event.native?.target;
          if (target && target instanceof HTMLElement) {
            target.style.cursor = elements[0] ? "pointer" : "default";
          }
        },
      },
    });
  },
};
