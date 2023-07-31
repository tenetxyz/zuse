// vite.config.ts
import { defineConfig } from "file:///Users/dhvani/Documents/Tenet/AW/voxel-aw/node_modules/vite/dist/node/index.js";
import react from "file:///Users/dhvani/Documents/Tenet/AW/voxel-aw/node_modules/@vitejs/plugin-react/dist/index.mjs";
import path from "path";
import { optimizeCssModules } from "file:///Users/dhvani/Documents/Tenet/AW/voxel-aw/node_modules/vite-plugin-optimize-css-modules/dist/index.mjs";
var __vite_injected_original_dirname = "/Users/dhvani/Documents/Tenet/AW/voxel-aw/packages/client";
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
    dedupe: ["proxy-deep", "styled-components"],
    alias: {
      "@": path.resolve(__vite_injected_original_dirname, "./src"),
      "@tenetxyz": path.resolve(__vite_injected_original_dirname, "../")
    }
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
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcudHMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCIvVXNlcnMvZGh2YW5pL0RvY3VtZW50cy9UZW5ldC9BVy92b3hlbC1hdy9wYWNrYWdlcy9jbGllbnRcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZmlsZW5hbWUgPSBcIi9Vc2Vycy9kaHZhbmkvRG9jdW1lbnRzL1RlbmV0L0FXL3ZveGVsLWF3L3BhY2thZ2VzL2NsaWVudC92aXRlLmNvbmZpZy50c1wiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9pbXBvcnRfbWV0YV91cmwgPSBcImZpbGU6Ly8vVXNlcnMvZGh2YW5pL0RvY3VtZW50cy9UZW5ldC9BVy92b3hlbC1hdy9wYWNrYWdlcy9jbGllbnQvdml0ZS5jb25maWcudHNcIjtpbXBvcnQgeyBkZWZpbmVDb25maWcgfSBmcm9tIFwidml0ZVwiO1xuaW1wb3J0IHJlYWN0IGZyb20gXCJAdml0ZWpzL3BsdWdpbi1yZWFjdFwiO1xuaW1wb3J0IHBhdGggZnJvbSBcInBhdGhcIjtcbmltcG9ydCB7IG9wdGltaXplQ3NzTW9kdWxlcyB9IGZyb20gXCJ2aXRlLXBsdWdpbi1vcHRpbWl6ZS1jc3MtbW9kdWxlc1wiO1xuXG4vLyBodHRwczovL3d3dy5ucG1qcy5jb20vcGFja2FnZS92aXRlLXBsdWdpbi1yZXF1aXJlLXRyYW5zZm9ybVxuZXhwb3J0IGRlZmF1bHQgZGVmaW5lQ29uZmlnKHtcbiAgcGx1Z2luczogW3JlYWN0KCksIG9wdGltaXplQ3NzTW9kdWxlcygpXSxcbiAgc2VydmVyOiB7XG4gICAgaG9zdDogXCIwLjAuMC4wXCIsXG4gICAgcG9ydDogMzAwMCxcbiAgICBmczoge1xuICAgICAgc3RyaWN0OiBmYWxzZSxcbiAgICB9LFxuICB9LFxuICBidWlsZDoge1xuICAgIG1pbmlmeTogXCJ0ZXJzZXJcIixcbiAgICB0ZXJzZXJPcHRpb25zOiB7XG4gICAgICBjb21wcmVzczogdHJ1ZSxcbiAgICAgIGtlZXBfY2xhc3NuYW1lczogZmFsc2UsXG4gICAgICBrZWVwX2ZuYW1lczogZmFsc2UsXG4gICAgICB0b3BsZXZlbDogdHJ1ZSxcbiAgICAgIG1hbmdsZTogdHJ1ZSxcbiAgICB9LFxuICAgIG91dERpcjogXCJkaXN0XCIsXG4gICAgZW1wdHlPdXREaXI6IHRydWUsXG4gICAgc291cmNlbWFwOiBmYWxzZSxcbiAgICBhc3NldHNJbmxpbmVMaW1pdDogMCxcbiAgICB0YXJnZXQ6IFwiZXMyMDIyXCIsXG4gIH0sXG4gIHJlc29sdmU6IHtcbiAgICBkZWR1cGU6IFtcInByb3h5LWRlZXBcIiwgXCJzdHlsZWQtY29tcG9uZW50c1wiXSxcbiAgICBhbGlhczoge1xuICAgICAgXCJAXCI6IHBhdGgucmVzb2x2ZShfX2Rpcm5hbWUsIFwiLi9zcmNcIiksXG4gICAgICBcIkB0ZW5ldHh5elwiOiBwYXRoLnJlc29sdmUoX19kaXJuYW1lLCBcIi4uL1wiKSxcbiAgICB9LFxuICB9LFxuICBkZWZpbmU6IHtcbiAgICBnbG9iYWw6IFwiZ2xvYmFsVGhpc1wiLFxuICB9LFxuICBvcHRpbWl6ZURlcHM6IHtcbiAgICBlc2J1aWxkT3B0aW9uczoge1xuICAgICAgdGFyZ2V0OiBcImVzMjAyMlwiLFxuICAgIH0sXG4gICAgZXhjbHVkZTogW1wiQGxhdHRpY2V4eXovbm9pc2VcIiwgXCJidWZmZXJcIl0sXG4gIH0sXG59KTtcbiJdLAogICJtYXBwaW5ncyI6ICI7QUFBNlYsU0FBUyxvQkFBb0I7QUFDMVgsT0FBTyxXQUFXO0FBQ2xCLE9BQU8sVUFBVTtBQUNqQixTQUFTLDBCQUEwQjtBQUhuQyxJQUFNLG1DQUFtQztBQU16QyxJQUFPLHNCQUFRLGFBQWE7QUFBQSxFQUMxQixTQUFTLENBQUMsTUFBTSxHQUFHLG1CQUFtQixDQUFDO0FBQUEsRUFDdkMsUUFBUTtBQUFBLElBQ04sTUFBTTtBQUFBLElBQ04sTUFBTTtBQUFBLElBQ04sSUFBSTtBQUFBLE1BQ0YsUUFBUTtBQUFBLElBQ1Y7QUFBQSxFQUNGO0FBQUEsRUFDQSxPQUFPO0FBQUEsSUFDTCxRQUFRO0FBQUEsSUFDUixlQUFlO0FBQUEsTUFDYixVQUFVO0FBQUEsTUFDVixpQkFBaUI7QUFBQSxNQUNqQixhQUFhO0FBQUEsTUFDYixVQUFVO0FBQUEsTUFDVixRQUFRO0FBQUEsSUFDVjtBQUFBLElBQ0EsUUFBUTtBQUFBLElBQ1IsYUFBYTtBQUFBLElBQ2IsV0FBVztBQUFBLElBQ1gsbUJBQW1CO0FBQUEsSUFDbkIsUUFBUTtBQUFBLEVBQ1Y7QUFBQSxFQUNBLFNBQVM7QUFBQSxJQUNQLFFBQVEsQ0FBQyxjQUFjLG1CQUFtQjtBQUFBLElBQzFDLE9BQU87QUFBQSxNQUNMLEtBQUssS0FBSyxRQUFRLGtDQUFXLE9BQU87QUFBQSxNQUNwQyxhQUFhLEtBQUssUUFBUSxrQ0FBVyxLQUFLO0FBQUEsSUFDNUM7QUFBQSxFQUNGO0FBQUEsRUFDQSxRQUFRO0FBQUEsSUFDTixRQUFRO0FBQUEsRUFDVjtBQUFBLEVBQ0EsY0FBYztBQUFBLElBQ1osZ0JBQWdCO0FBQUEsTUFDZCxRQUFRO0FBQUEsSUFDVjtBQUFBLElBQ0EsU0FBUyxDQUFDLHFCQUFxQixRQUFRO0FBQUEsRUFDekM7QUFDRixDQUFDOyIsCiAgIm5hbWVzIjogW10KfQo=
