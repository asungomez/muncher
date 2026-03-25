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
