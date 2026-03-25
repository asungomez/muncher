import type { PillColor } from "../../components/Pill/Pill";

export type Pill = {
  name: string;
  color: PillColor;
};

export type Recipe = {
  id: string;
  imageUrl: string;
  name: string;
  description: string;
  pills: Pill[];
};
