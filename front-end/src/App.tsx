import I18nProvider from "./i18n/I18nProvider/I18nProvider";
import Routes from "./routes/Routes";

function App() {
  return (
    <I18nProvider>
      <Routes />
    </I18nProvider>
  );
}

export default App;
