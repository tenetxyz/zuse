import { tenetMudConfig } from "@tenetxyz/base-world";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  namespace: "world",
  tables: {
    Faucet: {
      registerAsRoot: true,
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        claimers: "address[]",
        claimerAmounts: "uint256[]",
      },
    },
    TerrainProperties: {
      // cache of terrain properties, used by simulator to save gas
      registerAsRoot: true,
      keySchema: {
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        properties: "bytes", // ObjectProperties
      },
    },
    Metadata: {
      registerAsRoot: true,
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        numRan: "uint32",
      },
    },
    // Object Type Tables
    AgentAction: {
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        isHit: "bool",
        targetObjectEntityId: "bytes32",
        damage: "uint32",
      },
    },
  },
  systems: {
    FaucetSystem: {
      name: "FaucetSystem",
      openAccess: true,
      registerAsRoot: true,
    },
  },
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Faucet")],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("TerrainProperties")],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("Mind")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Metadata")],
    },
  ],
});
