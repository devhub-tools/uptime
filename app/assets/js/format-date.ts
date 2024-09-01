import { html, LitElement } from "lit";
import { customElement, property } from "lit/decorators.js";
import { DateTime } from "luxon";

@customElement("format-datetime")
export default class FormatDateTime extends LitElement {
  @property()
  date: string;

  @property()
  format: string;

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
