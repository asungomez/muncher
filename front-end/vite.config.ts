import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    // The server always runs inside a container, reached from the host's
    // browser, so it must listen on every interface.
    host: true,
    // The client calls the API under /api on its own origin, which in
    // production the domain routes to the deployed API. Here that prefix is
    // forwarded to the API container, so no request is ever cross-origin and
    // the client needs no per-environment configuration.
    proxy: {
      "/api": {
        target: "http://api:9100",
        rewrite: (path) => path.replace(/^\/api/, ""),
      },
    },
    watch: {
      // The sources are bind mounted from the host, and a bind mount does not
      // deliver filesystem events to the container. Without polling the server
      // starts normally and simply never hot reloads.
      usePolling: true,
      interval: 300,
    },
  },
});
