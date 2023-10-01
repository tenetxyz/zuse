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
        lastUpdateBlock: "uint256", // TODO: Rename to lastUpdateCacheBlock?
        velocity: "bytes", // VoxelCoord, 3D vector
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
    ShardProperties: {
      keySchema: {
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        minNoise: "int128",
        maxNoise: "int128",
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
      accessList: [
        "ApprovalSystem", // TODO: should this be openAccess: false?
        "RunCASystem",
        "EnergySystem",
        "BuildSystem",
        "MineSystem",
        "ActivateSystem",
        "MoveSystem",
      ],
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
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("OwnedBy")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("BodyPhysics")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("ShardProperties")],
    },
  ],
});
