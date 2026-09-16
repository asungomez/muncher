import { useCallback, useMemo, useState, type ReactNode } from "react";
import { I18nContext } from "./context";

import es from "../locales/es.json";

interface I18nProviderProps {
  children: ReactNode;
}

type TranslationData = {
  [key: string]: string | TranslationData;
};

/** The locales with a translation file; `changeLocale` rejects anything else. */
const AVAILABLE_LANGUAGES = ["es"] as const;
type AvailableLanguage = (typeof AVAILABLE_LANGUAGES)[number];

const translations: Record<AvailableLanguage, TranslationData> = {
  es,
};

/** Makes the translation function and the active locale available to the tree. */
function I18nProvider({ children }: I18nProviderProps) {
  const [locale, setLocale] = useState<AvailableLanguage>("es");

  /** Ignores a locale that has no translations, leaving the current one. */
  const changeLocale = (newLocale: string) => {
    if (AVAILABLE_LANGUAGES.includes(newLocale as AvailableLanguage)) {
      setLocale(newLocale as AvailableLanguage);
    }
  };

  /**
   * Looks a dotted key path up in the active locale, interpolating `{{name}}`
   * placeholders from `params`. An unresolved path returns the key itself.
   */
  const t = useCallback(
    (key: string, params?: Record<string, unknown>): string => {
      const keys = key.split(".");

      let current: TranslationData | string | undefined = translations[locale];

      for (const k of keys) {
        if (current && typeof current === "object" && !Array.isArray(current)) {
          current = current[k];
        } else {
          current = undefined;
          break;
        }
      }

      if (typeof current !== "string") return key;

      let result = current;

      if (params) {
        Object.entries(params).forEach(([paramKey, paramValue]) => {
          result = result.replace(
            new RegExp(`{{${paramKey}}}`, "g"),
            String(paramValue),
          );
        });
      }

      return result;
    },
    [locale],
  );

  // Memoised so every consumer does not re-render on each provider render.
  const contextValue = useMemo(
    () => ({ locale, setLocale: changeLocale, t }),
    [locale, t],
  );

  return (
    <I18nContext.Provider value={contextValue}>{children}</I18nContext.Provider>
  );
}

export default I18nProvider;
