// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

const colors = {
  accent: {
    DEFAULT: "hsl(var(--accent))",
    foreground: "hsl(var(--accent-foreground))",
  },
  background: "hsl(var(--background))",
  border: "hsl(var(--border))",
  card: {
    DEFAULT: "hsl(var(--card))",
    foreground: "hsl(var(--card-foreground))",
  },
  foreground: "hsl(var(--foreground))",
  input: "hsl(var(--input))",
  muted: {
    DEFAULT: "hsl(var(--muted))",
    foreground: "hsl(var(--muted-foreground))",
  },
  popover: {
    DEFAULT: "hsl(var(--popover))",
    foreground: "hsl(var(--popover-foreground))",
  },
  primary: {
    DEFAULT: "hsl(var(--primary))",
    foreground: "hsl(var(--primary-foreground))",
  },
  ring: "hsl(var(--ring))",
  secondary: {
    DEFAULT: "hsl(var(--secondary))",
    foreground: "hsl(var(--secondary-foreground))",
  },
  destructive: {
    DEFAULT: "hsl(var(--destructive))",
    foreground: "hsl(var(--destructive-foreground))",
  },
  success: {
    DEFAULT: "hsl(var(--success))",
    foreground: "hsl(var(--success-foreground))",
  },
  warn: {
    DEFAULT: "hsl(var(--warn))",
    foreground: "hsl(var(--warn-foreground))",
  },
};

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["selector"],
  content: [
    "./js/**/*.js",
    "../lib/uptime_web.ex",
    "../lib/uptime_web/**/*.*ex",
  ],
  theme: {
    colors,
    plugins: [
      require("@tailwindcss/forms"),
      // Allows prefixing tailwind classes with LiveView classes to add rules
      // only when LiveView classes are applied, for example:
      //
      //     <div class="phx-click-loading:animate-ping">
      //
      plugin(({ addVariant }) =>
        addVariant("phx-click-loading", [
          ".phx-click-loading&",
          ".phx-click-loading &",
        ])
      ),
      plugin(({ addVariant }) =>
        addVariant("phx-submit-loading", [
          ".phx-submit-loading&",
          ".phx-submit-loading &",
        ])
      ),
      plugin(({ addVariant }) =>
        addVariant("phx-change-loading", [
          ".phx-change-loading&",
          ".phx-change-loading &",
        ])
      ),

      // Embeds Heroicons (https://heroicons.com) into your app.css bundle
      // See your `CoreComponents.icon/1` for more information.
      //
      plugin(function ({ matchComponents, theme }) {
        let iconsDir = path.join(__dirname, "../deps/heroicons/optimized");
        let values = {};
        let icons = [
          ["", "/24/outline"],
          ["-solid", "/24/solid"],
          ["-mini", "/20/solid"],
          ["-micro", "/16/solid"],
        ];
        icons.forEach(([suffix, dir]) => {
          fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
            let name = path.basename(file, ".svg") + suffix;
            values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
          });
        });
        matchComponents(
          {
            hero: ({ name, fullPath }) => {
              let content = fs
                .readFileSync(fullPath)
                .toString()
                .replace(/\r?\n|\r/g, "");
              let size = theme("spacing.6");
              if (name.endsWith("-mini")) {
                size = theme("spacing.5");
              } else if (name.endsWith("-micro")) {
                size = theme("spacing.4");
              }
              return {
                [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
                "-webkit-mask": `var(--hero-${name})`,
                mask: `var(--hero-${name})`,
                "mask-repeat": "no-repeat",
                "background-color": "currentColor",
                "vertical-align": "middle",
                display: "inline-block",
                width: size,
                height: size,
              };
            },
          },
          { values }
        );
      }),
    ],
  },
};
