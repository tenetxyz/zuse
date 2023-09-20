import { tenetMudConfig } from "@tenetxyz/base-ca";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  namespace: "ca",
  tables: {
    ElectronTunnelSpot: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        atTop: "bool",
        sibling: "bytes32",
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
    CACallerSystem: {
      name: "CACallerSystem",
      openAccess: false,
      registerAsRoot: true,
      accessList: ["AirVoxelSystem", "ElectronVoxelSystem", "ElectronSystem"],
    },
  },
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("ElectronTunnelSpot")],
    },
  ],
});
