import { tenetMudConfig } from "@tenetxyz/base-world";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  tables: {
    Player: {
      keySchema: {
        player: "address",
      },
      schema: {
        health: "uint256",
        stamina: "uint256",
        lastUpdateBlock: "uint256",
        lastUpdateCoord: "bytes", // VoxelCoord
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

    TruthTable: {
      schema: {
        creator: "address",
        numInputBits: "uint16",
        numOutputBits: "uint16",
        name: "string",
        description: "string",
        inputRows: "uint256[]", // Note: if the outputRows are always 2^n, then we don't even need the input rows. Since we can say the ith output row is for the ith input row (represented by binary number i)
        outputRows: "uint256[]",
      },
    },

    // CR = Classification Result
    TruthTableCR: {
      keySchema: {
        truthTableId: "bytes32",
        creationId: "bytes32",
      },
      schema: {
        blockNumber: "uint256",
        inInterfaces: "bytes", // so we know what the input/outputs are
        outInterfaces: "bytes",
      },
    },
  },
  systems: {
    RunCASystem: {
      name: "RunCASystem",
      openAccess: false,
      accessList: ["BuildSystem", "MineSystem", "ActivateVoxelSystem", "MoveSystem"],
    },
  },
  modules: [
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("OwnedBy")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Player")],
    },
  ],
});
