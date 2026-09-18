import { useI18n } from "../../i18n/I18nProvider/context";
import { toApiErrorKind } from "../../services/api/errors";
import { useRecipes } from "../../services/recipes/useRecipes";
import RecipesList from "../RecipesList/RecipesList";
import StatusMessage from "../StatusMessage/StatusMessage";

/** The recipe grid, or what is standing in its way: a failure, a wait or nothing to show. */
function RecipesSection() {
  const { t } = useI18n();
  const { recipes, error, isLoading, isSlow, retry } = useRecipes();

  if (error) {
    return (
      <StatusMessage
        message={t(`recipes.error.${toApiErrorKind(error)}`)}
        action={{ label: t("recipes.retry"), onClick: retry }}
      />
    );
  }

  if (isLoading) {
    return (
      <StatusMessage
        message={t("recipes.loading")}
        detail={isSlow ? t("recipes.slow") : undefined}
      />
    );
  }

  if (!recipes?.length) {
    return <StatusMessage message={t("recipes.empty")} />;
  }

  return <RecipesList recipes={recipes} />;
}

export default RecipesSection;
