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
        player: "address",
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
    Player: {
      keySchema: {
        player: "address",
      },
      schema: {
        health: "uint256",
        stamina: "uint256",
        lastUpdateBlock: "uint256",
        lastUpdateCoord: "bytes", // VoxelCoord
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
    Recipe: "bytes32",
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
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Player")],
    },
  ],
});
