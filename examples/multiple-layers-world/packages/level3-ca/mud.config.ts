import { tenetMudConfig } from "@tenetxyz/base-ca";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  namespace: "ca",
  tables: {},
  systems: {
    CASystem: {
      name: "CASystem",
      openAccess: true,
      registerAsRoot: true,
    },
    CAExternalSystem: {
      name: "CAExternalSystem",
      openAccess: true,
      registerAsRoot: true,
    },
    CAInteractionSystem: {
      name: "CAInteractionSys",
      openAccess: true,
      registerAsRoot: true,
    },
    CAHelperSystem: {
      name: "CAHelperSystem",
      openAccess: false,
      registerAsRoot: true,
      accessList: ["CASystem"],
    },
    CACallerSystem: {
      name: "CACallerSystem",
      openAccess: false,
      registerAsRoot: true,
      accessList: ["AirVoxelSystem", "RoadVoxelSystem"],
    },
  },
  modules: [],
});
