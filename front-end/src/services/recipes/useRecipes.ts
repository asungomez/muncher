import { useState } from "react";
import { useApiQuery } from "../api/client";

/**
 * The recipe collection from `GET /recipes`, re-rendering as it arrives, fails
 * or is revalidated.
 */
export function useRecipes() {
  const [isSlow, setIsSlow] = useState(false);

  const { data, error, isLoading, mutate } = useApiQuery(
    "/recipes",
    {},
    {
      onLoadingSlow: () => setIsSlow(true),
      onSuccess: () => setIsSlow(false),
      onError: () => setIsSlow(false),
    },
  );

  return {
    recipes: data,
    error,
    isLoading,
    isSlow,
    retry: () => mutate(),
  };
}
