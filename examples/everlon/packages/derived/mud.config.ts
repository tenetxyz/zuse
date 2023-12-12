import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  enums: {
    ElementType: ["None", "Fire", "Water", "Grass"],
  },
  tables: {
    CreatureLeaderboard: {
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        rank: "uint256",
      },
    },
    FarmLeaderboard: {
      keySchema: {
        // ShardCoords
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        rank: "uint256",
        totalProduction: "uint256",
        farmerObjectEntityId: "bytes32",
      },
    },
    BuildingLeaderboard: {
      keySchema: {
        // ShardCoords
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        rank: "uint256",
        totalLikes: "uint256",
        agentObjectEntityId: "bytes32",
        likedBy: "address[]",
      },
    },
    ClaimedShard: {
      keySchema: {
        agentObjectEntityId: "bytes32",
      },
      schema: {
        claimedShard: "bytes", // VoxelCoord
      },
    },
    FarmFactionsLeaderboard: {
      keySchema: {
        // ShardCoords
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        rank: "uint256",
        totalProduction: "uint256",
        farmerObjectEntityId: "bytes32",
        faction: "ElementType",
        isDisqualified: "bool",
      },
    },
    CreatureFactionsLeaderboard: {
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        rank: "uint256",
        isDisqualified: "bool",
      },
    },
    FarmDeliveryLeaderboard: {
      keySchema: {
        // ShardCoords
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        totalPoints: "uint256",
        numDeliveries: "uint256",
        agentObjectEntityId: "bytes32",
      },
    },
    OriginatingChunk: {
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
      },
    },
  },
  systems: {},
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("CreatureLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("FarmLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("FarmFactionsLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("CreatureFactionsLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("BuildingLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("FarmDeliveryLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("OriginatingChunk")],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("OriginatingChunk")],
    },
  ],
});
