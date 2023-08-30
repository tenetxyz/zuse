import { tenetMudConfig } from "@tenetxyz/base-ca";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  namespace: "ca",
  enums: {
    BlockDirection: ["None", "North", "South", "East", "West", "NorthEast", "NorthWest", "SouthEast", "SouthWest"],
  },
  tables: {
    Fighters: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        health: "int32",
        hasValue: "bool",
      },
    },
  },
  systems: {
    CASystem: {
      name: "CASystem",
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
      accessList: ["AirVoxelSystem", "DirtVoxelSystem", "GrassVoxelSystem", "BedrockVoxelSystem", "MoveForwardSystem"],
    },
    CAVoxelRegistrySystem: {
      name: "CAVoxelRegistryS",
      openAccess: true,
      registerAsRoot: true,
    },
  },
  modules: [],
});
