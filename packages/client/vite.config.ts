import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    host: "0.0.0.0",
    port: 3000,
    fs: {
      strict: false,
    },
  },
  build: {
    outDir: "dist",
    emptyOutDir: true,
    sourcemap: false,
    assetsInlineLimit: 0,
    target: "es2022",
  },
  resolve: {
    dedupe: ["proxy-deep", "styled-components"],
  },
  define: {
    global: "globalThis",
  },
  optimizeDeps: {
    esbuildOptions: {
      target: "es2022",
    },
    exclude: ["@latticexyz/noise", "buffer"],
  },
});
