import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  tables: {
    Mass: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        mass: "uint256",
      },
    },
    Energy: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        energy: "uint256",
      },
    },
    Velocity: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        velocity: "bytes", // VoxelCoord, 3D vector
        lastUpdateBlock: "uint256",
      },
    },
  },
  systems: {},
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Mass")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Energy")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Velocity")],
    },
  ],
});
