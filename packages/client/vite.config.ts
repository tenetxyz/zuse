import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";
import { optimizeCssModules } from "vite-plugin-optimize-css-modules";

// https://www.npmjs.com/package/vite-plugin-require-transform
export default defineConfig({
  plugins: [react(), optimizeCssModules()],
  server: {
    host: "0.0.0.0",
    port: 3003,
    fs: {
      strict: false,
    },
  },
  build: {
    minify: "terser",
    terserOptions: {
      compress: true,
      keep_classnames: false,
      keep_fnames: false,
      toplevel: true,
      mangle: true,
    },
    outDir: "dist",
    emptyOutDir: true,
    sourcemap: false,
    assetsInlineLimit: 0,
    target: "es2022",
  },
  resolve: {
    dedupe: ["proxy-deep", "styled-components"],
    alias: {
      "@": path.resolve(__dirname, "./src"),
      "@tenetxyz": path.resolve(__dirname, "../"),
    },
  },
  define: {
    global: "globalThis",
  },
  optimizeDeps: {
    esbuildOptions: {
      target: "es2022",
    },
    exclude: ["@latticexyz/noise"],
  },
});
