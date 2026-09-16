/** The colours a pill can be painted with. Mirrors `PillColor` in the API. */
export const PILL_COLORS = [
  "green",
  "blue",
  "yellow",
  "orange",
  "red",
  "amber",
  "pink",
  "lime",
  "sky",
  "rose",
] as const;
export type PillColor = (typeof PILL_COLORS)[number];
