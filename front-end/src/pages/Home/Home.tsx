import Button from "../../components/Button/Button";
import RecipesSection from "../../components/RecipesSection/RecipesSection";
import { useI18n } from "../../i18n/I18nProvider/context";

/** The landing page: the hero, laid out differently per breakpoint, and the recipe grid. */
function Home() {
  const { t } = useI18n();
  return (
    <>
      <section className="h-[33vh] relative w-screen left-1/2 -translate-x-1/2 -mt-8">
        {/* Mobile layout */}
        <div
          className="md:hidden h-full bg-cover bg-center bg-no-repeat flex flex-col items-center justify-center px-6 relative"
          style={{ backgroundImage: "url('/hero_section_image.png')" }}
        >
          <div className="absolute inset-0 bg-black/40" />
          <div className="relative z-10 flex flex-col items-center text-center">
            <h1 className="text-5xl font-bold text-white mb-2 drop-shadow-lg font-marker">
              {t("app.name")}
            </h1>
            <p className="text-white/90 text-lg mb-4 drop-shadow">
              {t("app.slogan")}
            </p>
            <Button>{t("home.call-to-action")}</Button>
          </div>
        </div>

        {/* Desktop layout */}
        <div className="hidden md:block h-full relative">
          {/* Image side - responsive width as base layer */}
          <div
            className="absolute top-0 left-0 h-full w-full md:w-2/3 bg-no-repeat bg-center lg:bg-left"
            style={{
              backgroundImage: "url('/hero_section_image.png')",
              backgroundSize: "auto 100%",
            }}
          />

          {/* Green side with diagonal - overlaps image */}
          <div
            className="absolute right-0 w-[55%] h-full bg-primary"
            style={{
              clipPath: "polygon(15% 0, 100% 0, 100% 100%, 0 100%)",
            }}
          />

          {/* Content container - respects main boundaries */}
          <div className="absolute inset-0 flex items-center">
            <div className="w-full max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 flex justify-end">
              <div className="w-1/2 flex flex-col items-center text-center">
                <h1 className="text-6xl font-bold text-white mb-2 font-marker">
                  {t("app.name")}
                </h1>
                <p className="text-white/90 text-xl mb-6">{t("app.slogan")}</p>
                <Button variant="secondary">{t("home.call-to-action")}</Button>
              </div>
            </div>
          </div>
        </div>
      </section>
      <RecipesSection />
    </>
  );
}

export default Home;
