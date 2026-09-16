import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

/**
 * Merges Tailwind classes, with later classes overriding earlier ones.
 *
 * @param inputs - Class values; falsy entries are dropped.
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
