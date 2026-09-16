import { FaGoogle } from "react-icons/fa";
import Button from "../Button/Button";
import { useI18n } from "../../i18n/I18nProvider/context";

/** The navbar's sign-in action. Renders the control only; it has no behaviour yet. */
function LogInButton() {
  const { t } = useI18n();
  return <Button icon={<FaGoogle />}>{t("authentication.log-in")}</Button>;
}

export default LogInButton;
