import { useI18n } from "../../i18n/I18nProvider/context";

function Footer() {
  const { t } = useI18n();
  return (
    <footer className="mt-10 bg-primary shadow-[inset_0_-6px_0_0_rgba(0,0,0,0.25)]">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8 text-white">
        <div className="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4">
          <div>
            <h2 className="text-2xl font-extrabold uppercase tracking-wider text-black font-marker">
              {t("app.name")}
            </h2>
            <p className="mt-1 text-sm text-black/90">{t("app.slogan")}</p>
          </div>
          <div className="text-sm text-black/95">
            <p className="font-semibold">{t("footer.contact")}:</p>
            <p>hola@muncher.io</p>
          </div>
        </div>
        <div className="mt-6 border-t border-black/40 pt-4 text-xs text-black/80">
          <p>{t("footer.copyright")}</p>
        </div>
      </div>
    </footer>
  );
}

export default Footer;
