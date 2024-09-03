import type { Hook } from "./helpers";
import { debounce } from "lodash";

type WindowResize = {
  resize?: (ev: Event) => void;
} & Hook;

export const WindowResizeHook: WindowResize = {
  mounted() {
    const update = debounce(() => {
      this.pushEvent?.("window_resize", {
        width: window.innerWidth,
        height: window.innerHeight,
      });
    }, 250);
    // Send initial window size
    update();
    // Watch for changes in the window size
    this.resize = (_ev: Event) => {
      update();
    };
    window.addEventListener("resize", this.resize);
  },
  destroyed() {
    if (this.resize) {
      window.removeEventListener("resize", this.resize);
    }
  },
};
