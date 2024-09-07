import { type Hook } from "./helpers";

const localStorageKey = "theme";

const isDark = () => {
  if (localStorage.getItem(localStorageKey) === "dark") return true;
  if (localStorage.getItem(localStorageKey) === "light") return false;
  return window.matchMedia("(prefers-color-scheme: dark)").matches;
};

const toggleTheme = (dark: boolean) => {
  const themeToggleDarkIcon = document.getElementById("theme-toggle-dark-icon");
  const themeToggleLightIcon = document.getElementById(
    "theme-toggle-light-icon"
  );
  if (
    themeToggleDarkIcon instanceof SVGElement &&
    themeToggleLightIcon instanceof SVGElement
  ) {
    const show = dark ? themeToggleDarkIcon : themeToggleLightIcon;
    const hide = dark ? themeToggleLightIcon : themeToggleDarkIcon;
    show.classList.remove("hidden", "text-transparent");
    hide.classList.add("hidden", "text-transparent");
    if (dark) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
    try {
      localStorage.setItem(localStorageKey, dark ? "dark" : "light");
    } catch (_err) {}
  }
};

toggleTheme(isDark());

type ThemeToggle = {
  toggle?: (ev: Event) => void;
  button?: HTMLButtonElement;
} & Hook;

export const ThemeToggleHook: ThemeToggle = {
  mounted() {
    this.toggle = (_ev) => {
      toggleTheme(!isDark());
    };
    const button = document.getElementById("theme-toggle");
    if (button instanceof HTMLButtonElement) {
      button.addEventListener("click", this.toggle);
    }
  },

  destroyed() {
    if (this.toggle && this.button) {
      this.button.removeEventListener("click", this.toggle);
    }
  },
};
