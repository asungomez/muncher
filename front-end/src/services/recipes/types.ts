import type { components } from "../api/schema";

/** A recipe as served by `GET /recipes`. */
export type Recipe = components["schemas"]["Recipe"];

/** A tag classifying a recipe. */
export type Pill = components["schemas"]["Pill"];
