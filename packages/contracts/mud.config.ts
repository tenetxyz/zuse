import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "tenet",
  enums: {
    NoaBlockType: ["BLOCK", "MESH"],
  },
  tables: {
    Name: "string", // Used to name players
    VoxelType: {
      // TODO: Move this to a namespace?
      schema: {
        voxelTypeNamespace: "bytes16",
        voxelTypeId: "bytes32",
        // TODO: Move this to its own type as keyof VoxelVariants
        voxelVariantNamespace: "bytes16",
        voxelVariantId: "bytes32",
      },
    },
    VoxelVariants: {
      keySchema: {
        voxelVariantNamespace: "bytes16",
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
    VoxelTypeRegistry: {
      // TODO: Move this to a namespace?
      keySchema: {
        voxelTypeNamespace: "bytes16",
        voxelTypeId: "bytes32",
      },
      schema: {
        previewVoxelVariantNamespace: "bytes16",
        previewVoxelVariantId: "bytes32",
        enterWorldSelector: "bytes4",
        exitWorldSelector: "bytes4",
        voxelVariantSelector: "bytes4",
        activateSelector: "bytes4",
        creator: "address",
        numSpawns: "uint256",
        name: "string", // NOTE: you don't want the VoxelTypeId to be based on the name, cause changing the name would change the ID
      },
    },
    Occurrence: {
      // Each voxel generates at diff spots in the world, and each voxel has a function defining where it should appear.
      // This table points to each voxel's respective generation function.
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
    VoxelInteractionExtension: {
      keySchema: {
        namespace: "bytes16",
        eventHandler: "bytes4",
      },
      schema: {
        placeholder: "bool",
      },
    },
    Recipe: "bytes32",
    // tables for creations
    Creation: {
      schema: {
        creator: "address",
        numSpawns: "uint256",
        voxelTypes: "bytes", // VoxelTypeData[]
        relativePositions: "bytes", // VoxelCoord[], the relative position for each voxel in the creation
        name: "string",
        description: "string",
        // voxelMetadata: "bytes", // stores the component values for each voxel in the creation
        // Note: can't add more dynamic fields cause rn we can only have at most 5 dynamic fields: https://github.com/tenetxyz/mud/blob/main/packages/store/src/Schema.sol#L20
      },
    },

    // tables for spawning
    OfSpawn: "bytes32", // maps a voxel spawned in the world -> the entityId representing its spawn
    Spawn: {
      schema: {
        creationId: "bytes32", // the creation that it's a spawn of
        isModified: "bool", // modified spawns can't be submitted to classifiers
        lowerSouthWestCorner: "bytes", // "VoxelCoord
        voxels: "bytes32[]", // the voxelIds that have been spawned
      },
    },
    Classifier: {
      // the id is just the classifierId
      schema: {
        creator: "address",
        classifySelector: "bytes4", // the function that will be called when the user submits to the classifier
        // namespace: "bytes16", // the namespace of the classifier (and its classification result table)
        name: "string",
        description: "string",
        selectorInterface: "bytes", // InterfaceVoxels[] the interface that the classifier will use
        classificationResultTableName: "string", // needed so the client can know which table to query for the classification result
      },
    },
  },
  systems: {
    VoxelInteractionSystem: {
      name: "VoxInteractSys", // Note: This has to be <= 16 characters and can't conflict with table names
      openAccess: false, // it's a subsystem now, so only systems in this namespace can call it
      accessList: ["MineSystem", "BuildSystem"],
    },
    RegisterClassifierSystem: {
      name: "RegClassifierSys", // Note: This has to be <= 16 characters and can't conflict with table names
      openAccess: true,
    },
  },
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Position")],
    },
    {
      name: "UniqueEntityModule",
      root: true,
      args: [],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("VoxelInteractionExtension")],
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
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("VoxelTypeRegistry")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("VoxelVariants")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Classifier")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Spawn")],
    },
  ],
});
