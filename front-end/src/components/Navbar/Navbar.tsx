import { NavLink } from "react-router";
import LogInButton from "../LogInButton/LogInButton";
import { useI18n } from "../../i18n/I18nProvider/context";

function Navbar() {
  const { t } = useI18n();
  return (
    <nav className="bg-white w-full shadow-sm">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-2">
        <div className="flex items-center justify-between">
          <NavLink to="/">
            <img
              src="/muncher_logo.png"
              alt={t("home.home")}
              className="h-12"
            />
          </NavLink>
          <LogInButton />
        </div>
      </div>
    </nav>
  );
}

export default Navbar;
