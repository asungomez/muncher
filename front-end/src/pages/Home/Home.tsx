import Button from "../../components/Button/Button";
import RecipesList from "../../components/RecipesList/RecipesList";
import type { Recipe } from "../../services/recipes/types";

const mockRecipes: Recipe[] = [
  {
    id: "1",
    name: "Bol de verduras frescas",
    description:
      "Un bol colorido lleno de verduras frescas, granos y una deliciosa vinagreta.",
    imageUrl:
      "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=880&q=80",
    pills: [
      { name: "Vegetariano", color: "green" },
      { name: "Sano", color: "blue" },
      { name: "Rápido", color: "yellow" },
    ],
  },
  {
    id: "2",
    name: "Pasta Picante con Pollo",
    description:
      "Una pasta cremosa y picante con pollo que satisfará tus antojos.",
    imageUrl:
      "https://www.zizzi.co.uk/propeller/uploads/2022/07/casareccia-pollo-piccante-e1667309010824.jpg",
    pills: [
      { name: "Pasta", color: "green" },
      { name: "Picante", color: "red" },
      { name: "Pollo", color: "amber" },
    ],
  },
  {
    id: "3",
    name: "Mousse de Chocolate con Aguacate",
    description:
      "Un postre decadente y saludable hecho con aguacate cremoso y chocolate rico, perfecto para satisfacer tu antojo de dulce sin culpa.",
    imageUrl:
      "https://www.trops.es/wp-content/uploads/2020/03/mousse-aguacate-chocolate-1024x683.jpg",
    pills: [
      { name: "Postre", color: "pink" },
      { name: "Sano", color: "blue" },
      { name: "Vegano", color: "green" },
    ],
  },
  {
    id: "4",
    name: "Smoothie Verde Energizante",
    description:
      "Un smoothie refrescante y rico en antioxidantes para comenzar tu día.",
    imageUrl: "https://www.hazteveg.com/img/recipes/full/201612/R03-65246.jpg",
    pills: [
      { name: "Desayuno", color: "green" },
      { name: "Rápido", color: "yellow" },
      { name: "Frutas", color: "lime" },
    ],
  },
];

function Home() {
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
      <RecipesList recipes={mockRecipes} />
    </>
  );
}

export default Home;
