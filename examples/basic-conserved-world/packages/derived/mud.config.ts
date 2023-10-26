import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  enums: {
    ObjectType: ["None", "Fire", "Water", "Grass"],
  },
  tables: {
    PokemonLeaderboard: {
      keySchema: {
        caEntity: "bytes32",
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
        farmerCAEntity: "bytes32",
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
        agentEntity: "bytes32",
        likedBy: "address[]",
      },
    },
    // This is like the reverse mapping of claimedShards
    ClaimedShards: {
      keySchema: {
        agentEntity: "bytes32",
      },
      schema: {
        claimedShards: "bytes", // VoxelCoord[]
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
        // rank: "uint256", // commented since this can be easily made out-of-date. we can also derive it in JS
        totalPoints: "uint256",
        numDeliveries: "uint256",
        agentCAEntity: "bytes32",
      },
    },
    OriginatingChunk: {
      keySchema: {
        caEntity: "bytes32",
      },
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
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
        farmerCAEntity: "bytes32",
        faction: "ObjectType",
        isDisqualified: "bool",
      },
    },
    PokemonFactionsLeaderboard: {
      keySchema: {
        caEntity: "bytes32",
      },
      schema: {
        rank: "uint256",
        isDisqualified: "bool",
      },
    },
  },
  systems: {},
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("PokemonLeaderboard")],
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
      args: [resolveTableId("PokemonFactionsLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("BuildingLeaderboard")],
    },
    {
      name: "KeysWithValueModule",
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
