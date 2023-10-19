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
  },
  systems: {},
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("PokemonLeaderboard")],
    },
  ],
});
