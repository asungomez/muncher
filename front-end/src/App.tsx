import { SWRConfig } from "swr";
import I18nProvider from "./i18n/I18nProvider/I18nProvider";
import Routes from "./routes/Routes";
import { SWR_CONFIG } from "./services/api/client";

/** The application root: the global providers wrapped around the router. */
function App() {
  return (
    <SWRConfig value={SWR_CONFIG}>
      <I18nProvider>
        <Routes />
      </I18nProvider>
    </SWRConfig>
  );
}

export default App;
