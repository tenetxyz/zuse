import { tenetMudConfig } from "@tenetxyz/base-world";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  tables: {
    BodyPhysics: {
      keySchema: {
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        mass: "uint256",
        energy: "uint256",
        velocity: "bytes", // VoxelCoord, 3D vector
        gravity: "bytes", // VoxelCoord, 3D vector
      },
    },
    VoxelTypeProperties: {
      keySchema: {
        voxelTypeId: "bytes32",
      },
      schema: {
        mass: "uint256",
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
  },
  systems: {
    RunCASystem: {
      name: "RunCASystem",
      openAccess: false,
      accessList: ["BuildSystem", "MineSystem", "ActivateSystem", "MoveSystem"],
    },
    EnergySystem: {
      name: "EnergySystem",
      openAccess: false,
      accessList: ["VelocitySystem", "BuildSystem", "MineSystem", "ActivateSystem", "MoveSystem"],
    },
    VelocitySystem: {
      name: "VelocitySystem",
      openAccess: false,
      accessList: ["EnergySystem", "BuildSystem", "MineSystem", "ActivateSystem", "MoveSystem"],
    },
    FluxSystem: {
      name: "FluxSystem",
      openAccess: false,
      accessList: ["CAEventsSystem"],
    },
  },
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("OwnedBy")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("BodyPhysics")],
    },
  ],
});
