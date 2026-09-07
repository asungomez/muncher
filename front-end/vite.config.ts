import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

// The dev server runs inside a container while the sources stay on the host.
// File changes arrive through a bind mount, which does not deliver filesystem
// events reliably, so the watcher has to poll for hot reloading to work.
const inContainer = process.env.MUNCHER_IN_CONTAINER === "1";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: inContainer
    ? {
        host: true,
        watch: {
          usePolling: true,
          interval: 300,
        },
      }
    : undefined,
});
