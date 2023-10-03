import { tenetMudConfig } from "@tenetxyz/base-world";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  tables: {
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
      args: [resolveTableId("TerrainProperties")],
    },
  ],
});
