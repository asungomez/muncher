import RecipeCard from "../RecipeCard/RecipeCard";
import type { Recipe } from "../../services/recipes/types";
import { RECIPE_CARD_VARIANTS } from "../RecipeCard/utils";

interface RecipesListProps {
  recipes: Recipe[];
}

function RecipesList({ recipes }: RecipesListProps) {
  return (
    <section className="py-8">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-12 pt-4">
          {recipes.map((recipe, index) => (
            <RecipeCard
              key={recipe.id}
              recipe={recipe}
              variant={
                RECIPE_CARD_VARIANTS[index % RECIPE_CARD_VARIANTS.length]
              }
            />
          ))}
        </div>
      </div>
    </section>
  );
}

export default RecipesList;
