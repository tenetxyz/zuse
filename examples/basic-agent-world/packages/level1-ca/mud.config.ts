import { tenetMudConfig } from "@tenetxyz/base-ca";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  namespace: "ca",
  tables: {
    Health: {
      keySchema: {
        entity: "bytes32",
      },
      schema: {
        health: "uint32",
      },
    },
    Stamina: {
      keySchema: {
        entity: "bytes32",
      },
      schema: {
        stamina: "uint32",
      },
    },
    State: {
      keySchema: {
        entity: "bytes32",
      },
      schema: {
        state: "string",
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
  modules: [],
});
