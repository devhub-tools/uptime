import { createPopper } from "@popperjs/core";

// A class to manage the tooltip lifecycle.
export class Tooltip {
  showEvents = ["mouseenter", "focus"];
  hideEvents = ["mouseleave", "blur"];
  $parent;
  $tooltip;
  popperInstance;

  constructor($tooltip) {
    this.$tooltip = $tooltip;
    this.$parent = $tooltip.parentElement;
    this.popperInstance = createPopper(this.$parent, $tooltip, {
      modifiers: [
        {
          name: "offset",
          options: {
            offset: [0, -5],
          },
        },
      ],
    });
    this.destructors = [];
    this.showEvents.forEach((event) => {
      const callback = this.show.bind(this);
      this.$parent.addEventListener(event, callback);
      this.destructors.push(() =>
        this.$parent.removeEventListener(event, callback)
      );
    });

    this.hideEvents.forEach((event) => {
      const callback = this.hide.bind(this);
      this.$parent.addEventListener(event, callback);
      this.destructors.push(() =>
        this.$parent.removeEventListener(event, callback)
      );
    });
  }

  show() {
    this.$tooltip.setAttribute("data-show", "");
    this.update();
  }

  update() {
    this.popperInstance?.update();
  }

  hide() {
    this.$tooltip.removeAttribute("data-show");
  }

  destroy() {
    this.destructors.forEach((destructor) => destructor());
    this.popperInstance?.destroy();
  }
}
