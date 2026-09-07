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
    watch: {
      // The sources are bind mounted from the host, and a bind mount does not
      // deliver filesystem events to the container. Without polling the server
      // starts normally and simply never hot reloads.
      usePolling: true,
      interval: 300,
    },
  },
});
