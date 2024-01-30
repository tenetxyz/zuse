import { tenetMudConfig } from "@tenetxyz/base-simulator";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  enums: {
    SimTable: ["None", "Mass", "Energy"],
  },
  tables: {
    Mass: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        mass: "uint256",
      },
    },
    Energy: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        energy: "uint256",
      },
    },
  },
  systems: {},
  modules: [
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("Mass")],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("Energy")],
    },
  ],
});
