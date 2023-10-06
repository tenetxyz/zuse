import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  enums: {
    PokemonMove: [
      "None",
      "Ember",
      "FlameBurst",
      "SmokeScreen",
      "FireShield",
      "WaterGun",
      "HydroPump",
      "Bubble",
      "AquaRing",
      "VineWhip",
      "SolarBeam",
      "LeechSeed",
      "Synthesis",
    ],
  },
  tables: {
    Mass: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        mass: "uint256",
      },
    },
    Energy: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        energy: "uint256",
      },
    },
    Velocity: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        lastUpdateBlock: "uint256",
        velocity: "bytes", // VoxelCoord, 3D vector
      },
    },
    Health: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        health: "uint256",
      },
    },
    Stamina: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        stamina: "uint256",
      },
    },
    Move: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        move: "PokemonMove",
        round: "int32",
      },
    },
  },
  systems: {
    EnergyHelperSystem: {
      name: "EnergyHelperSyst",
      openAccess: false,
      accessList: ["MassSystem", "EnergySystem"],
    },
  },
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
