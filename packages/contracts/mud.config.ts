import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "tenet",
  enums: {
    NoaBlockType: ["BLOCK", "MESH"],
  },
  tables: {
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
        voxelVariantId: "bytes32", // TODO: Should be a string?
      },
      schema: {
        variantId: "uint256",
        frames: "uint32",
        opaque: "bool",
        fluid: "bool",
        solid: "bool",
        blockType: "NoaBlockType",
        // Note: These 2 dynamic fields MUST come at the end of the schema
        materialArr: "string", // File ID Hash[], TODO: Use a more efficient data structure
        uvWrap: "string", // File ID Hash
      },
    },
    VoxelTypeRegistry: {
      // TODO: Move this to a namespace?
      keySchema: {
        namespace: "bytes16",
        voxelType: "bytes32",
      },
      schema: {
        voxelVariantSelector: "bytes4",
        preview: "string", // File ID Hash
      },
    },
    Name: "string", // This is a shortcut for { schema: "string" }
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
    Stake: "uint32",
    Claim: {
      schema: {
        stake: "uint32",
        claimer: "bytes32",
      },
    },

    // tables for creations
    Creation: {
      schema: {
        creator: "bytes32",
        voxelTypes: "bytes", // VoxelTypeData[]
        // the relative position for each voxel in the creation
        // VoxelCoord is removed in MUD2, so we need to manually specify x,y,z
        relativePositionsX: "uint32[]",
        relativePositionsY: "uint32[]",
        relativePositionsZ: "uint32[]",
        name: "string",
        // description: "string", // Not used cause rn we can only have at most 5 dynamic fields: https://github.com/tenetxyz/mud/blob/main/packages/store/src/Schema.sol#L20
        // voxelMetadata: "bytes", // stores the component values for each voxel in the creation
      },
    },

    // tables for spawning
    OfSpawn: "bytes32", // maps a voxel spawned in the world -> the entityId representing its spawn
    Spawn: {
      schema: {
        creationId: "bytes32", // the creation that it's a spawn of
        lowerSouthWestCornerX: "int32",
        lowerSouthWestCornerY: "int32",
        lowerSouthWestCornerZ: "int32",
        voxels: "bytes32[]", // the voxelIds that have been spawned
        interfaceVoxels: "bytes32[]", // the voxels that are used for i/o interfaces (e.g. for an AND gate test)
      },
    },
    Classifier: {
      // the id is just the classifierId
      schema: {
        creator: "address",
        classifySelector: "bytes4", // the function that will be called when the user submits to the classifier
        name: "string",
        description: "string",
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
  ],
});
