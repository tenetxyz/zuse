import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  enums: {
    NoaBlockType: ["BLOCK", "MESH"],
  },
  tables: {
    VoxelTypeRegistry: {
      keySchema: {
        voxelTypeId: "bytes32",
      },
      schema: {
        caAddress: "address",
        previewVoxelVariantId: "bytes32",
        creator: "address",
        numSpawns: "uint256",
        name: "string",
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
      args: [resolveTableId("VoxelTypeRegistry")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("VoxelVariantsRegistry")],
    },
  ],
});
