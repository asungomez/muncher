import React from "react";

type I18nContextParams = {
  locale: string;
  setLocale: (locale: string) => void;
  t: (key: string, params?: Record<string, unknown>) => string;
};

/** Defaults to Spanish and to echoing the key, for consumers outside a provider. */
export const I18nContext = React.createContext<I18nContextParams>({
  locale: "es",
  setLocale: () => {},
  t: (key: string) => key,
});

/** Gives access to the current locale and to the `t` translation function. */
export const useI18n = () => React.useContext(I18nContext);
