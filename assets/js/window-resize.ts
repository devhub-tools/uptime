import type { Hook } from "./helpers";

type WindowResize = {
  resize?: (ev: Event) => void;
} & Hook;

export const WindowResizeHook: WindowResize = {
  mounted() {
    // Send initial window size
    this.pushEvent?.("window_resize", {
      width: window.innerWidth,
      height: window.innerHeight,
    });
    // Watch for changes in the window size
    this.resize = (_ev: Event) => {
      this.pushEvent?.("window_resize", {
        width: window.innerWidth,
        height: window.innerHeight,
      });
    };
    window.addEventListener("resize", this.resize);
  },
  destroyed() {
    if (this.resize) {
      window.removeEventListener("resize", this.resize);
    }
  },
};
