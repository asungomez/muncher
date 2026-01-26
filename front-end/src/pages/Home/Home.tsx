import Button from "../../components/Button/Button";

function Home() {
  return (
    <section className="h-[33vh] relative w-screen left-1/2 -translate-x-1/2 -mt-8">
      {/* Mobile layout */}
      <div
        className="md:hidden h-full bg-cover bg-center bg-no-repeat flex flex-col items-center justify-center px-6 relative"
        style={{ backgroundImage: "url('/hero_section_image.webp')" }}
      >
        <div className="absolute inset-0 bg-black/40" />
        <div className="relative z-10 flex flex-col items-center text-center">
          <h1 className="text-3xl font-bold text-white mb-2 drop-shadow-lg">
            Muncher
          </h1>
          <p className="text-white/90 text-lg mb-4 drop-shadow">
            Comer sano no tiene que ser aburrido
          </p>
          <Button>Empezar</Button>
        </div>
      </div>

      {/* Desktop layout */}
      <div className="hidden md:block h-full relative">
        {/* Image side - full width as base layer */}
        <div
          className="absolute inset-0 bg-cover bg-center bg-no-repeat"
          style={{ backgroundImage: "url('/hero_section_image.webp')" }}
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
              <h1 className="text-4xl font-bold text-white mb-2">Muncher</h1>
              <p className="text-white/90 text-xl mb-6">
                Comer sano no tiene que ser aburrido
              </p>
              <Button variant="secondary">Empezar</Button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export default Home;
