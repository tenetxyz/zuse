import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "ca",
  tables: {
    CAPosition: {
      registerAsRoot: true,
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        // VoxelCoord is removed in MUD2, so we need to manually specify x,y,z
        x: "int32",
        y: "int32",
        z: "int32",
      },
    },
    CAVoxelType: {
      registerAsRoot: true,
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        voxelTypeId: "bytes32",
        voxelVariantId: "bytes32",
      },
    },
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
    CACallerSystem: {
      name: "CACallerSystem",
      openAccess: false,
      registerAsRoot: true,
      accessList: ["AirVoxelSystem", "ElectronVoxelSystem", "ElectronSystem"],
    },
  },
  modules: [
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
      args: [resolveTableId("ElectronTunnelSpot")],
    },
  ],
});
