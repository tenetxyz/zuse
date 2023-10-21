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
        farmer: "address",
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
        farmer: "address",
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
  ],
});
