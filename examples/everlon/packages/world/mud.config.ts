import { tenetMudConfig } from "@tenetxyz/base-world";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  namespace: "world",
  tables: {
    Faucet: {
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        claimers: "address[]",
        claimerAmounts: "uint256[]",
      },
    },
    Shard: {
      keySchema: {
        // ShardCoords
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        claimer: "address",
        contractAddress: "address",
        objectTypeIdSelector: "bytes4",
        objectPropertiesSelector: "bytes4",
        totalGenMass: "uint256",
        totalGenEnergy: "uint256",
      },
    },
    TerrainProperties: {
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
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        numRan: "uint32",
      },
    },
  },
  systems: {},
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Faucet")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Shard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("TerrainProperties")],
    },
  ],
});
