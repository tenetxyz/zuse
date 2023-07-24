// vite.config.ts
import { defineConfig } from "file:///Users/curtischong/Documents/dev/voxel-aw/node_modules/vite/dist/node/index.js";
import react from "file:///Users/curtischong/Documents/dev/voxel-aw/node_modules/@vitejs/plugin-react/dist/index.mjs";
import { optimizeCssModules } from "file:///Users/curtischong/Documents/dev/voxel-aw/node_modules/vite-plugin-optimize-css-modules/dist/index.mjs";
var vite_config_default = defineConfig({
  plugins: [react(), optimizeCssModules()],
  server: {
    host: "0.0.0.0",
    port: 3e3,
    fs: {
      strict: false
    }
  },
  build: {
    minify: "terser",
    terserOptions: {
      compress: true,
      keep_classnames: false,
      keep_fnames: false,
      toplevel: true,
      mangle: true
    },
    outDir: "dist",
    emptyOutDir: true,
    sourcemap: false,
    assetsInlineLimit: 0,
    target: "es2022"
  },
  resolve: {
    dedupe: ["proxy-deep", "styled-components"]
  },
  define: {
    global: "globalThis"
  },
  optimizeDeps: {
    esbuildOptions: {
      target: "es2022"
    },
    exclude: ["@latticexyz/noise", "buffer"]
  }
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCIvVXNlcnMvY3VydGlzY2hvbmcvRG9jdW1lbnRzL2Rldi92b3hlbC1hdy9wYWNrYWdlcy9jbGllbnRcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZmlsZW5hbWUgPSBcIi9Vc2Vycy9jdXJ0aXNjaG9uZy9Eb2N1bWVudHMvZGV2L3ZveGVsLWF3L3BhY2thZ2VzL2NsaWVudC92aXRlLmNvbmZpZy50c1wiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9pbXBvcnRfbWV0YV91cmwgPSBcImZpbGU6Ly8vVXNlcnMvY3VydGlzY2hvbmcvRG9jdW1lbnRzL2Rldi92b3hlbC1hdy9wYWNrYWdlcy9jbGllbnQvdml0ZS5jb25maWcudHNcIjtpbXBvcnQgeyBkZWZpbmVDb25maWcgfSBmcm9tIFwidml0ZVwiO1xuaW1wb3J0IHJlYWN0IGZyb20gXCJAdml0ZWpzL3BsdWdpbi1yZWFjdFwiO1xuaW1wb3J0IHsgb3B0aW1pemVDc3NNb2R1bGVzIH0gZnJvbSBcInZpdGUtcGx1Z2luLW9wdGltaXplLWNzcy1tb2R1bGVzXCI7XG5cbi8vIGh0dHBzOi8vd3d3Lm5wbWpzLmNvbS9wYWNrYWdlL3ZpdGUtcGx1Z2luLXJlcXVpcmUtdHJhbnNmb3JtXG5leHBvcnQgZGVmYXVsdCBkZWZpbmVDb25maWcoe1xuICBwbHVnaW5zOiBbcmVhY3QoKSwgb3B0aW1pemVDc3NNb2R1bGVzKCldLFxuICBzZXJ2ZXI6IHtcbiAgICBob3N0OiBcIjAuMC4wLjBcIixcbiAgICBwb3J0OiAzMDAwLFxuICAgIGZzOiB7XG4gICAgICBzdHJpY3Q6IGZhbHNlLFxuICAgIH0sXG4gIH0sXG4gIGJ1aWxkOiB7XG4gICAgbWluaWZ5OiBcInRlcnNlclwiLFxuICAgIHRlcnNlck9wdGlvbnM6IHtcbiAgICAgIGNvbXByZXNzOiB0cnVlLFxuICAgICAga2VlcF9jbGFzc25hbWVzOiBmYWxzZSxcbiAgICAgIGtlZXBfZm5hbWVzOiBmYWxzZSxcbiAgICAgIHRvcGxldmVsOiB0cnVlLFxuICAgICAgbWFuZ2xlOiB0cnVlLFxuICAgIH0sXG4gICAgb3V0RGlyOiBcImRpc3RcIixcbiAgICBlbXB0eU91dERpcjogdHJ1ZSxcbiAgICBzb3VyY2VtYXA6IGZhbHNlLFxuICAgIGFzc2V0c0lubGluZUxpbWl0OiAwLFxuICAgIHRhcmdldDogXCJlczIwMjJcIixcbiAgfSxcbiAgcmVzb2x2ZToge1xuICAgIGRlZHVwZTogW1wicHJveHktZGVlcFwiLCBcInN0eWxlZC1jb21wb25lbnRzXCJdLFxuICB9LFxuICBkZWZpbmU6IHtcbiAgICBnbG9iYWw6IFwiZ2xvYmFsVGhpc1wiLFxuICB9LFxuICBvcHRpbWl6ZURlcHM6IHtcbiAgICBlc2J1aWxkT3B0aW9uczoge1xuICAgICAgdGFyZ2V0OiBcImVzMjAyMlwiLFxuICAgIH0sXG4gICAgZXhjbHVkZTogW1wiQGxhdHRpY2V4eXovbm9pc2VcIiwgXCJidWZmZXJcIl0sXG4gIH0sXG59KTtcbiJdLAogICJtYXBwaW5ncyI6ICI7QUFBNlYsU0FBUyxvQkFBb0I7QUFDMVgsT0FBTyxXQUFXO0FBQ2xCLFNBQVMsMEJBQTBCO0FBR25DLElBQU8sc0JBQVEsYUFBYTtBQUFBLEVBQzFCLFNBQVMsQ0FBQyxNQUFNLEdBQUcsbUJBQW1CLENBQUM7QUFBQSxFQUN2QyxRQUFRO0FBQUEsSUFDTixNQUFNO0FBQUEsSUFDTixNQUFNO0FBQUEsSUFDTixJQUFJO0FBQUEsTUFDRixRQUFRO0FBQUEsSUFDVjtBQUFBLEVBQ0Y7QUFBQSxFQUNBLE9BQU87QUFBQSxJQUNMLFFBQVE7QUFBQSxJQUNSLGVBQWU7QUFBQSxNQUNiLFVBQVU7QUFBQSxNQUNWLGlCQUFpQjtBQUFBLE1BQ2pCLGFBQWE7QUFBQSxNQUNiLFVBQVU7QUFBQSxNQUNWLFFBQVE7QUFBQSxJQUNWO0FBQUEsSUFDQSxRQUFRO0FBQUEsSUFDUixhQUFhO0FBQUEsSUFDYixXQUFXO0FBQUEsSUFDWCxtQkFBbUI7QUFBQSxJQUNuQixRQUFRO0FBQUEsRUFDVjtBQUFBLEVBQ0EsU0FBUztBQUFBLElBQ1AsUUFBUSxDQUFDLGNBQWMsbUJBQW1CO0FBQUEsRUFDNUM7QUFBQSxFQUNBLFFBQVE7QUFBQSxJQUNOLFFBQVE7QUFBQSxFQUNWO0FBQUEsRUFDQSxjQUFjO0FBQUEsSUFDWixnQkFBZ0I7QUFBQSxNQUNkLFFBQVE7QUFBQSxJQUNWO0FBQUEsSUFDQSxTQUFTLENBQUMscUJBQXFCLFFBQVE7QUFBQSxFQUN6QztBQUNGLENBQUM7IiwKICAibmFtZXMiOiBbXQp9Cg==
