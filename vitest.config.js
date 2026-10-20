import { defineConfig } from "vitest/config";

import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: "jsdom",
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov", "json-summary"],
      include: ["src/**/*.{js,vue}"],
      exclude: ["src/main.js", "src/**/*.spec.js"],
    },
  },
});
