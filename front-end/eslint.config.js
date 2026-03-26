import js from "@eslint/js";
import globals from "globals";
import reactHooks from "eslint-plugin-react-hooks";
import reactRefresh from "eslint-plugin-react-refresh";
import tseslint from "typescript-eslint";
import { globalIgnores } from "eslint/config";
import cspellPlugin from "@cspell/eslint-plugin";
import * as jsonParser from "jsonc-eslint-parser";

export default tseslint.config([
  globalIgnores(["dist"]),
  {
    files: ["**/*.{ts,tsx}"],
    extends: [
      js.configs.recommended,
      tseslint.configs.recommended,
      reactHooks.configs["recommended-latest"],
      reactRefresh.configs.vite,
    ],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
    },
    rules: {
      "no-debugger": "error",
      "no-eval": "error",
      "no-console": "error",
    },
  },
  {
    files: ["src/i18n/locales/*.json"],
    languageOptions: {
      parser: jsonParser, // Use the imported parser object
    },
    plugins: {
      "@cspell": cspellPlugin, // Define as an object, not a string array
    },
    rules: {
      "@cspell/spellchecker": [
        "error",
        {
          // Adjusting scopes to ONLY check keys
          checkScope: [
            ["JSONProperty[key] JSONLiteral", false], // Ignore keys
            ["JSONProperty[value] JSONLiteral", true], // Target values
          ],
        },
      ],
    },
  },
]);
