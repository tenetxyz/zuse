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
        voxelTypeId: "bytes32",
      },
      schema: {
        scale: "uint32",
        previewVoxelVariantId: "bytes32",
        baseVoxelTypeId: "bytes32",
        minds: "bytes", // Mind[]
        selectors: "bytes", // VoxelSelectors
        metadata: "bytes", // CreationMetadata
        childVoxelTypeIds: "bytes32[]",
        schemaVoxelTypeIds: "bytes32[]", // This is used when a child is built to figure out if the parent should be built. We can't juse use childVoxelTypeIds, because the child entities may move
      },
    },
    VoxelVariantsRegistry: {
      keySchema: {
        voxelVariantId: "bytes32",
      },
      schema: {
        variantId: "uint256", // Used by the client
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
    CreationRegistry: {
      keySchema: {
        creationId: "bytes32",
      },
      schema: {
        numVoxels: "uint32", // The total number of voxels in this creation (including the voxels in the base creations). This value is really important to prevent extra computation when determining the voxels in base creations
        voxelTypes: "bytes", // VoxelTypeData[]
        relativePositions: "bytes", // VoxelCoord[], the relative position for each voxel in the creation
        baseCreations: "bytes", // it is called "base" creation - cause of "base class" in c++. To make composable creations work, root creations are comprised of these base creations.
        metadata: "bytes", // CreationMetadata
        // Note: can't add more dynamic fields cause rn we can only have at most 5 dynamic fields: https://github.com/tenetxyz/mud/blob/main/packages/store/src/Schema.sol#L20
      },
    },
    ClassifierRegistry: {
      keySchema: {
        classifierId: "bytes32",
      },
      schema: {
        creator: "address",
        classifySelector: "bytes4", // the function that will be called when the user submits to the classifier
        name: "string",
        description: "string",
        selectorInterface: "bytes", // InterfaceVoxel[] the interface that the classifier will use
        classificationResultTableName: "string", // needed so the client can know which table to query for the classification result
      },
    },
  },
  systems: {
    CreationRegistrySystem: {
      name: "CreationRegSys",
      openAccess: true,
    },
    ClassifierRegistrySystem: {
      name: "ClassifierRegSys",
      openAccess: true,
    },
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
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("CreationRegistry")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("ClassifierRegistry")],
    },
  ],
});
