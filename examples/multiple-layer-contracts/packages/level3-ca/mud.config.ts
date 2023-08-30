import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "ca",
  tables: {
    CAEntityMapping: {
      registerAsRoot: true,
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        caEntity: "bytes32",
      },
    },
    CAEntityReverseMapping: {
      registerAsRoot: true,
      keySchema: {
        caEntity: "bytes32",
      },
      schema: {
        callerAddress: "address",
        entity: "bytes32",
      },
    },
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
    CAMind: {
      registerAsRoot: true,
      keySchema: {
        caEntity: "bytes32",
      },
      schema: {
        voxelTypeId: "bytes32",
        mindSelector: "bytes4",
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
      accessList: ["AirVoxelSystem", "RoadVoxelSystem"],
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
  ],
});