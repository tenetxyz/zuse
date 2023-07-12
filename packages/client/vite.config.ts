import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { nodePolyfills } from "vite-plugin-node-polyfills";
import requireTransform from "vite-plugin-require-transform";

// https://www.npmjs.com/package/vite-plugin-require-transform
export default defineConfig({
  plugins: [
    react(),
    // nodePolyfills({
    //   // Whether to polyfill `node:` protocol imports.
    //   protocolImports: true,
    // }),
    // requireTransform({
    //   fileRegex: /.ts$|.tsx$/,
    //   importPrefix: "_vite_plugin_require_transform_",
    // }),
  ],
  server: {
    host: "0.0.0.0",
    port: 3000,
    fs: {
      strict: false,
    },
  },
  build: {
    minify: true,
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
