import { useCallback, useMemo, useState, type ReactNode } from "react";
import { I18nContext } from "./context";

import es from "../locales/es.json";

interface I18nProviderProps {
  children: ReactNode;
}

type TranslationData = {
  [key: string]: string | TranslationData;
};

const AVAILABLE_LANGUAGES = ["es"] as const;
type AvailableLanguage = (typeof AVAILABLE_LANGUAGES)[number];

const translations: Record<AvailableLanguage, TranslationData> = {
  es,
};

function I18nProvider({ children }: I18nProviderProps) {
  const [locale, setLocale] = useState<AvailableLanguage>("es");

  const changeLocale = (newLocale: string) => {
    if (AVAILABLE_LANGUAGES.includes(newLocale as AvailableLanguage)) {
      setLocale(newLocale as AvailableLanguage);
    }
  };

  const t = useCallback(
    (key: string, params?: Record<string, unknown>): string => {
      const keys = key.split(".");

      // We start with the full dictionary for the current locale
      let current: TranslationData | string | undefined = translations[locale];

      for (const k of keys) {
        // If 'current' is an object, we can look inside it
        if (current && typeof current === "object" && !Array.isArray(current)) {
          current = current[k];
        } else {
          // If we hit a string or undefined before we finish the keys, the path is invalid
          current = undefined;
          break;
        }
      }

      // If we didn't find a string at the end, return the key as a fallback
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

  // Memoize the value to prevent unnecessary re-renders of all consumers
  const contextValue = useMemo(
    () => ({ locale, setLocale: changeLocale, t }),
    [locale, t],
  );

  return (
    <I18nContext.Provider value={contextValue}>{children}</I18nContext.Provider>
  );
}

export default I18nProvider;
