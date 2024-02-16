import { tenetMudConfig } from "@tenetxyz/base-world";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  namespace: "world",
  tables: {
    // TODO: Move into base-world
    Recipes: {
      registerAsRoot: true,
      keySchema: {
        recipeId: "bytes32",
      },
      schema: {
        inputObjectTypeIds: "bytes32[]",
        inputObjectTypeAmounts: "uint32[]",
        outputObjectTypeIds: "bytes32[]",
        outputObjectTypeAmounts: "uint32[]",
        outputObjectProperties: "bytes", // ObjectProperties[]
      },
    },
    Faucet: {
      registerAsRoot: true,
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        claimers: "address[]",
        claimerAmounts: "uint256[]",
        claimerObjectEntityIds: "bytes", // bytes32[][]
      },
    },
    AgentFaucet: {
      registerAsRoot: true,
      keySchema: {
        agentObjectEntityId: "bytes32",
      },
      schema: {
        faucetObjectEntityId: "bytes32",
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
    ObjectMetadata: {
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
    RecipeSystem: {
      name: "RecipeSystem",
      openAccess: true,
      registerAsRoot: true,
    },
    CraftSystem: {
      name: "CraftSystem",
      openAccess: true,
      registerAsRoot: true,
    },
    FaucetSystem: {
      name: "FaucetSystem",
      openAccess: true,
      registerAsRoot: true,
    },
  },
  modules: [
    {
      // TODO: This is only needed for tests, so we should remove it from production
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Recipes")],
    },
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
      args: [resolveTableId("ObjectMetadata")],
    },
  ],
});
