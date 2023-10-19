import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  enums: {},
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
        farmer: "address",
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
