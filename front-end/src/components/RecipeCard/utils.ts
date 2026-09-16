/** The background and tilt combinations a recipe card cycles through. */
export const RECIPE_CARD_VARIANTS = [
  "primary",
  "secondary",
  "tertiary",
  "quaternary",
] as const;
export type RecipeCardVariant = (typeof RECIPE_CARD_VARIANTS)[number];
