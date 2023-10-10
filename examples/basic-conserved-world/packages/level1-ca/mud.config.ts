import { tenetMudConfig } from "@tenetxyz/base-ca";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  namespace: "ca",
  tables: {
    TerrainSelectors: {
      registerAsRoot: true,
      keySchema: {
        callerAddress: "address",
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        contractAddress: "address",
        selector: "bytes4",
      },
    },
  },
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
    CAVoxelRegistrySystem: {
      name: "CAVoxelRegistryS",
      openAccess: true,
      registerAsRoot: true,
    },
  },
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("TerrainSelectors")],
    },
  ],
});
