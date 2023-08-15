import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "ca",
  enums: {
    BlockDirection: ["None", "North", "South", "East", "West", "NorthEast", "NorthWest", "SouthEast", "SouthWest"],
  },
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
