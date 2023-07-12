import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { minify } from "terser";
import { optimizeCssModules } from "vite-plugin-optimize-css-modules";

// https://github.com/vitejs/vite/issues/6555
// function minifyBundles() {
//   return {
//     name: "minifyBundles",
//     async generateBundle(options, bundle) {
//       for (let key in bundle) {
//         if (bundle[key].type == "chunk" && key.endsWith(".js")) {
//           const minifyCode = await minify(bundle[key].code, { sourceMap: false });
//           bundle[key].code = minifyCode.code;
//         }
//       }
//       return bundle;
//     },
//   };
// }

export default defineConfig({
  plugins: [react(), optimizeCssModules()],
  server: {
    host: "0.0.0.0",
    port: 3000,
    fs: {
      strict: false,
    },
  },
  build: {
    minify: "terser",
    terserOptions: {
      keep_fnames: false,
      mangle: {
        toplevel: true,
        module: true,
      },
    },
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
