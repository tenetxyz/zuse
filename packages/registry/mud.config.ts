import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

/**
 * Importing this enables "snap sync mode".
 * It allows clients to sync the latest state of the world using view functions.
 */
import "@latticexyz/world/snapsync";

export default mudConfig({
  enums: {
    NoaBlockType: ["BLOCK", "MESH"],
  },
  snapSync: true,
  tables: {
    WorldRegistry: {
      keySchema: {
        worldAddress: "address",
      },
      schema: {
        creator: "address",
        name: "string",
        description: "string",
        caAddresses: "address[]",
      },
    },
    CARegistry: {
      keySchema: {
        caAddress: "address",
      },
      schema: {
        scale: "uint32",
        creator: "address",
        name: "string",
        description: "string",
        voxelTypeIds: "bytes32[]",
      },
    },
    VoxelTypeRegistry: {
      keySchema: {
        voxelTypeId: "bytes32", // AKA voxelBaseTypeId
      },
      schema: {
        scale: "uint32",
        previewVoxelVariantId: "bytes32",
        creator: "address",
        numSpawns: "uint256",
        name: "string",
        childVoxelTypeIds: "bytes32[]",
        schemaVoxelTypeIds: "bytes32[]",
      },
    },
    VoxelVariantsRegistry: {
      keySchema: {
        voxelVariantId: "bytes32",
      },
      schema: {
        variantId: "uint256",
        frames: "uint32",
        opaque: "bool",
        fluid: "bool",
        solid: "bool",
        blockType: "NoaBlockType",
        // Note: These 2 dynamic fields MUST come at the end of the schema
        materials: "bytes", // string[]
        uvWrap: "string", // File ID Hash
      },
    },
  },
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("WorldRegistry")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("CARegistry")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("VoxelTypeRegistry")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("VoxelVariantsRegistry")],
    },
  ],
});
