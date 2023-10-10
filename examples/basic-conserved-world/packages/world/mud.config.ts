import { tenetMudConfig } from "@tenetxyz/base-world";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  tables: {
    Faucet: {
      keySchema: {
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        claimers: "address[]",
        claimerAmounts: "uint256[]",
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
        terrainSelector: "bytes4",
        verified: "bool",
        buckets: "bytes", // BucketData[]
      },
    },
    TerrainProperties: {
      keySchema: {
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        bucketIndex: "uint8",
      },
    },
  },
  systems: {
    RunCASystem: {
      name: "RunCASystem",
      openAccess: false,
      accessList: ["BuildSystem", "MineSystem", "ActivateSystem", "MoveSystem"],
    },
  },
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Faucet")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("OwnedBy")],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("OwnedBy")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("TerrainProperties")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("TerrainSelectors")],
    },
  ],
});
