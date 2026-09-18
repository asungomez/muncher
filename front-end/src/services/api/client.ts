import createClient from "openapi-fetch";
import type { SWRConfiguration } from "swr";
import { createQueryHook } from "swr-openapi";
import type { paths } from "./schema";

/**
 * The API answers under this prefix on the front-end's own origin: the
 * development server proxies it to the API container (see `vite.config.ts`) and
 * the deployed domain routes it to the deployed API. Nothing is configured per
 * environment, and no request is ever cross-origin.
 */
const BASE_URL = "/api";

/** How long a request may run before it is abandoned and reported as an error. */
const REQUEST_TIMEOUT_MS = 10_000;

/** How long a request may run before it is treated as slow but still pending. */
const SLOW_REQUEST_MS = 2_000;

/**
 * Applies the timeout on top of whatever signal the caller passed, so a request
 * that never answers fails instead of leaving the interface pending forever.
 */
const fetchWithTimeout: typeof fetch = (input, init) => {
  const timeout = AbortSignal.timeout(REQUEST_TIMEOUT_MS);
  return fetch(input, {
    ...init,
    signal: init?.signal ? AbortSignal.any([init.signal, timeout]) : timeout,
  });
};

const client = createClient<paths>({
  baseUrl: BASE_URL,
  fetch: fetchWithTimeout,
});

/**
 * The defaults every request shares, applied by the `SWRConfig` in `App.tsx`.
 *
 * `onLoadingSlow` fires at `loadingTimeout`, which is what lets a hook report
 * slowness while the request is still in flight.
 */
export const SWR_CONFIG: SWRConfiguration = {
  loadingTimeout: SLOW_REQUEST_MS,
  errorRetryCount: 2,
  keepPreviousData: true,
  revalidateOnFocus: false,
};

/**
 * A typed `useSWR`: the path, its parameters and the shape of the response are
 * all taken from the API's schema, so none of them is written twice.
 *
 * The error is `unknown` because a request fails in ways the schema does not
 * describe — a timeout, a broken connection — as well as in the ways it does.
 * `toApiErrorKind` in `errors.ts` narrows it.
 */
export const useApiQuery = createQueryHook<
  paths,
  `${string}/${string}`,
  "muncher",
  unknown
>(client, "muncher");
