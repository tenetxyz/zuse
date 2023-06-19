import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "tenet",
  tables: {
    VoxelType: "bytes32", // maps a voxel's entityId -> its type
    VoxelPrototype: "bool",
    Name: "string", // This is a shortcut for { schema: "string" }
    Description: "string",
    Occurrence: {
      // Each voxel generates at diff spots in the world, and each voxel has a function defining where it should appear. This table points to each voxel's respective generation function.
      schema: {
        functionPointer: "bytes4",
      },
    },
    OwnedBy: "bytes32",
    Position: {
      schema: {
        // VoxelCoord is removed in MUD2, so we need to manually specify x,y,z
        x: "int32",
        y: "int32",
        z: "int32",
      },
    },
    Extension: {
      keySchema: {
        namespace: "bytes16",
      },
      schema: {
        eventHandler: "bytes4",
      },
    },
    Recipe: "bytes32",
    Stake: "uint32",
    Claim: {
      schema: {
        stake: "uint32",
        claimer: "bytes32",
      },
    },

    // tables for creations
    VoxelTypes: "bytes32[]", // stores the voxelTypes for a creation
    Positions: {
      schema: {
        // VoxelCoord is removed in MUD2, so we need to manually specify x,y,z
        x: "int32[]",
        y: "int32[]",
        z: "int32[]",
      },
    },
    VoxelMetadata: "bytes" // stores the component values for each voxel in the creation
  },
  modules: [
    {
      name: "UniqueEntityModule",
      root: true,
      args: [],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Extension")],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("Position")],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("OwnedBy")],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("VoxelType")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("VoxelType")],
    },
  ],
});
