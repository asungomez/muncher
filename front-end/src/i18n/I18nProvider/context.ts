import React from "react";

type I18nContextParams = {
  locale: string;
  setLocale: (locale: string) => void;
  t: (key: string, params?: Record<string, unknown>) => string;
};

export const I18nContext = React.createContext<I18nContextParams>({
  locale: "es",
  setLocale: () => {},
  t: (key: string) => key,
});

export const useI18n = () => React.useContext(I18nContext);
