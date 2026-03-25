import type { Recipe } from "../../services/recipes/types";
import Pill from "../Pill/Pill";
import type { RecipeCardVariant } from "./utils";

interface RecipeCardProps {
  recipe: Recipe;
  variant: RecipeCardVariant;
}

const cardVariants: Record<RecipeCardVariant, { bg: string; rotate: string }> =
  {
    primary: { bg: "bg-secondary", rotate: "transform -rotate-1" },
    secondary: { bg: "bg-primary", rotate: "transform rotate-2" },
    tertiary: { bg: "bg-tertiary", rotate: "transform rotate-1" },
    quaternary: { bg: "bg-quaternary", rotate: "transform -rotate-2" },
  };

function RecipeCard({
  recipe: { name, description, imageUrl, pills },
  variant,
}: RecipeCardProps) {
  const style = cardVariants[variant];

  return (
    <div
      className={`shadow-lg bg-white transform transition-transform duration-300 ease-in-out font-sans p-2 border-4 border-black hover:scale-105 hover:rotate-0 ${style.rotate}`}
    >
      <div className={`${style.bg} p-4 h-full flex flex-col justify-between`}>
        <img
          className="w-full h-48 object-cover border-4 border-black"
          src={imageUrl}
          alt={`Imagen de ${name}`}
        />
        <div className="px-1 py-4">
          <div className="font-bold text-xl mb-2 text-gray-800 font-block">
            {name}
          </div>
          <p className="text-gray-700 text-base">{description}</p>
        </div>
        <div className="px-1 pt-4 pb-2">
          {pills.map((pill) => (
            <Pill key={pill.name} content={pill.name} color={pill.color} />
          ))}
        </div>
      </div>
    </div>
  );
}

export default RecipeCard;
