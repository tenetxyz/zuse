import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["ts/index.ts"],
  target: "esnext",
  format: ["esm"],
  dts: false,
  sourcemap: true,
  clean: true,
  minify: true,
  external: ["@latticexyz/world/register", "@latticexyz/config", "@latticexyz/common/type-utils", "@latticexyz/store/config", "@latticexyz/store/register"]
});