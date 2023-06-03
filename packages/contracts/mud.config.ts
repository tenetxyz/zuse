import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  tables: {
    Item: "bytes32",
    ItemPrototype: "bool",
    Name: "string", // This is a shortcut for { schema: "string" }
    Occurrence: { // Each block generates at diff spots in the world, and each block has a function defining where it should appear. This table points to each block's respective generation function.
      schema: {
        functionPointer: "bytes4"
      }
    },
    OwnedBy: "bytes32",
    Position: {
      schema: { // VoxelCoord is removed in MUD2, so we need to manually specify x,y,z
        x: "int32",
        y: "int32",
        z: "int32"
      }
    },
    Recipe: "bytes32",
    Stake: "uint32",
    Claim: {
      schema: {
        stake: "uint32",
        claimer: "bytes32",
      }
    },
  },
  modules: [
    {
      name: "UniqueEntityModule",
      root: true,
      args: [],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("Position")],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("OwnedBy")],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("Item")],
    },
  ],
});
