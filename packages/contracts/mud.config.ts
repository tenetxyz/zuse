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
    WorldConfig: {
      keySchema: {
        voxelTypeId: "bytes32",
      },
      schema: {
        caAddress: "address",
      },
    },
    VoxelType: {
      keySchema: {
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        voxelTypeId: "bytes32", // TODO: rename to voxelBaseTypeId
        voxelVariantId: "bytes32",
      },
    },
    VoxelActivated: {
      keySchema: {
        player: "bytes32",
      },
      schema: {
        scale: "uint32",
        entity: "bytes32",
        message: "string",
      },
      ephemeral: true,
    },
    Position: {
      keySchema: {
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        // VoxelCoord is removed in MUD2, so we need to manually specify x,y,z
        x: "int32",
        y: "int32",
        z: "int32",
      },
    },
    OwnedBy: {
      keySchema: {
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        player: "address",
      },
    },
    Name: "string", // Used to name players
    Recipe: "bytes32",
    // tables for creations
    Creation: {
      schema: {
        creator: "address",
        numSpawns: "uint256",
        numVoxels: "uint32", // The total number of voxels in this creation (including the voxels in the base creations). This value is really important to prevent extra computation when determining the voxels in base creations
        voxelTypes: "bytes", // VoxelTypeData[]
        relativePositions: "bytes", // VoxelCoord[], the relative position for each voxel in the creation
        name: "string",
        description: "string",
        // voxelMetadata: "bytes", // stores the component values for each voxel in the creation
        // Note: can't add more dynamic fields cause rn we can only have at most 5 dynamic fields: https://github.com/tenetxyz/mud/blob/main/packages/store/src/Schema.sol#L20
        baseCreations: "bytes", // it is called "base" creation - cause of "base class" in c++. To make composable creations work, root creations are comprised of these base creations.
      },
    },

    // tables for spawning
    OfSpawn: {
      // maps a voxel spawned in the world -> the entityId representing its spawn
      keySchema: {
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        spawnId: "bytes32",
      },
    },
    Spawn: {
      schema: {
        creationId: "bytes32", // the creation that it's a spawn of
        isModified: "bool", // modified spawns can't be submitted to classifiers
        lowerSouthWestCorner: "bytes", // VoxelCoord
        voxels: "bytes", // the voxel entities that have been spawned
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

    Player: {
      keySchema: {
        player: "address",
      },
      schema: {
        health: "uint32",
        stamina: "uint32",
      },
    },
  },
  systems: {
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
      args: [resolveTableId("WorldConfig")],
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
      args: [resolveTableId("Classifier")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Spawn")],
    },
  ],
});
