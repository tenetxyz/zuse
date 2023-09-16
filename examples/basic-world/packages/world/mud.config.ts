import { tenetMudConfig } from "@tenetxyz/base-world";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  tables: {},
  systems: {
    RunCASystem: {
      name: "RunCASystem",
      openAccess: false,
      accessList: ["BuildSystem", "MineSystem", "ActivateVoxelSystem", "MoveSystem"],
    },
  },
  modules: [],
});
