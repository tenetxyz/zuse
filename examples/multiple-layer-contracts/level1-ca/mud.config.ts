import { tenetMudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig(
  {
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
        name: "UniqueEntityModule",
        root: true,
        args: [],
      },
      {
        name: "KeysWithValueModule",
        root: true,
        args: [resolveTableId("CAPosition")],
      },
      {
        name: "KeysInTableModule",
        root: true,
        args: [resolveTableId("CAPosition")],
      },
      {
        name: "KeysInTableModule",
        root: true,
        args: [resolveTableId("CAVoxelType")],
      },
      {
        name: "KeysInTableModule",
        root: true,
        args: [resolveTableId("CAEntityMapping")],
      },
      {
        name: "KeysInTableModule",
        root: true,
        args: [resolveTableId("CAEntityReverseMapping")],
      },
      {
        name: "KeysInTableModule",
        root: true,
        args: [resolveTableId("CAMind")],
      },
      {
        name: "KeysInTableModule",
        root: true,
        args: [resolveTableId("ElectronTunnelSpot")],
      },
    ],
  },
  true
);
