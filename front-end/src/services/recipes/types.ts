import type { PillColor } from "../../components/Pill/utils";

/** A tag classifying a recipe, as served by the API. */
export type Pill = {
  name: string;
  color: PillColor;
};

/** A recipe as served by `GET /recipes`, mirroring the API model in camelCase. */
export type Recipe = {
  id: string;
  imageUrl: string;
  name: string;
  description: string;
  pills: Pill[];
};
