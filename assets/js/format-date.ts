import { html, LitElement } from "lit";
import { customElement, property } from "lit/decorators.js";
import { DateTime } from "luxon";

@customElement("format-datetime")
export default class FormatDateTime extends LitElement {
  timerInterval: number;

  @property()
  date: string;

  @property()
  format: string;

  connectedCallback() {
    super.connectedCallback();
    if (this.format === "relative") {
      this.timerInterval = setInterval(() => this.requestUpdate(), 1000);
    }
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    if (this.timerInterval !== undefined) {
      clearInterval(this.timerInterval);
    }
  }

  render() {
    const dt = DateTime.fromISO(this.date);

    switch (this.format) {
      case "date":
        return html` ${dt.toLocaleString(DateTime.DATE_MED)} `;
      case "relative":
        return html` ${dt.toRelative()} `;
      default:
        return html` ${dt.toLocaleString(DateTime.DATETIME_MED_WITH_SECONDS)} `;
    }
  }
}
