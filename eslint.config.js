import eslintPlugin from "eslint-plugin-vue";

export default [
  ...eslintPlugin.configs["flat/recommended"],
  {
    files: ["**/*.{js,vue}"],
    languageOptions: { ecmaVersion: "latest", sourceType: "module" },
    rules: {
      "no-console": "warn",
      "no-unused-vars": "warn",
      "vue/multi-word-component-names": "off",
    },
  },
  { ignores: ["dist/**", "coverage/**", "node_modules/**"] },
];
