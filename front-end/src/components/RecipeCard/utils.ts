export const RECIPE_CARD_VARIANTS = [
  "primary",
  "secondary",
  "tertiary",
] as const;
export type RecipeCardVariant = (typeof RECIPE_CARD_VARIANTS)[number];
