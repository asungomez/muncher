/** What went wrong with a request, as far as the interface needs to care. */
export type ApiErrorKind = "timeout" | "offline" | "server";

/**
 * Classifies whatever a request threw, so a component can explain the failure
 * without inspecting it.
 *
 * `AbortSignal.timeout` rejects with a `TimeoutError`, and `fetch` rejects with
 * a `TypeError` when the request never reached the server; anything else
 * arrived as a response the API refused to fulfil.
 */
export function toApiErrorKind(error: unknown): ApiErrorKind {
  if (error instanceof DOMException && error.name === "TimeoutError") {
    return "timeout";
  }

  if (error instanceof TypeError) {
    return "offline";
  }

  return "server";
}
