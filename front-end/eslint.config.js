import js from "@eslint/js";
import globals from "globals";
import reactHooks from "eslint-plugin-react-hooks";
import reactRefresh from "eslint-plugin-react-refresh";
import tseslint from "typescript-eslint";
import { globalIgnores } from "eslint/config";
import cspellPlugin from "@cspell/eslint-plugin";
import jsdoc from "eslint-plugin-jsdoc";
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
    plugins: { jsdoc },
    rules: {
      "no-debugger": "error",
      "no-eval": "error",
      "no-console": "error",

      // Mirrors Ruff's FIX001-FIX004 on the API: work worth doing belongs in an
      // issue. Matches the term at the start of the comment, as Ruff does.
      "no-warning-comments": [
        "error",
        { terms: ["todo", "fixme", "xxx", "hack"], location: "start" },
      ],

      // Enforces agents/front-end/docstrings.md. The plugin's own recommended
      // preset is not extended: it demands the @param and @returns that our
      // convention forbids, TypeScript already carrying the types.
      "jsdoc/require-jsdoc": [
        "error",
        {
          require: { FunctionDeclaration: true },
          // Hooks and helpers written as arrows. Only those bound to a name;
          // callbacks passed inline are not declarations.
          contexts: ["VariableDeclarator > ArrowFunctionExpression"],
        },
      ],
      "jsdoc/require-description": "error",
      "jsdoc/no-types": "error",
      "jsdoc/check-alignment": "error",
      "jsdoc/check-tag-names": ["error", { typed: true }],
      "jsdoc/require-param-description": "error",
      "jsdoc/require-hyphen-before-param-description": "error",
      "jsdoc/tag-lines": ["error", "any", { startLines: 1 }],
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
