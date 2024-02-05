import { tenetMudConfig } from "@tenetxyz/base-simulator";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  enums: {
    SimTable: ["None", "Mass", "Energy", "Velocity", "Health", "Stamina"],
    MoveTrigger: ["None", "Gravity", "Collision"],
  },
  tables: {
    Metadata: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        lastInteractionBlock: "uint256",
      },
    },
    Mass: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        mass: "uint256",
      },
    },
    Energy: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        energy: "uint256",
      },
    },
    Velocity: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        lastUpdateBlock: "uint256",
        velocity: "bytes", // VoxelCoord
      },
    },
    Health: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        lastUpdateBlock: "uint256",
        health: "uint256",
      },
    },
    Stamina: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        stamina: "uint256",
      },
    },
    MoveMetadata: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
        oldPosX: "int32",
        oldPosY: "int32",
        oldPosZ: "int32",
        newPosX: "int32",
        newPosY: "int32",
        newPosZ: "int32",
      },
      schema: {
        moveTrigger: "MoveTrigger",
      },
    },
  },
  systems: {
    // Rules should only be called by world systems
    FluxEnergyRuleSystem: {
      name: "FluxEnergyRuleSy",
      openAccess: false,
      accessList: ["VelocityRuleSystem", "MassConstraintSystem", "StaminaVelocityConstraintSystem"],
    },
    CollisionRuleSystem: {
      name: "CollisionRuleSys",
      openAccess: false,
      accessList: ["WorldMoveEventSystem"],
    },
    GravityRuleSystem: {
      name: "GravityRuleSyste",
      openAccess: false,
      accessList: [
        "VelocityRuleSystem",
        "WorldMoveEventSystem",
        "WorldBuildEventSystem",
        "WorldMineEventSystem",
        "WorldActivateEventSystem",
      ],
    },
    VelocityRuleSystem: {
      name: "VelocityRuleSyst",
      openAccess: false,
      accessList: [
        "WorldMoveEventSystem",
        "WorldBuildEventSystem",
        "WorldMineEventSystem",
        "WorldActivateEventSystem",
        "WorldObjectEventSystem",
        "StaminaVelocityConstraintSystem",
      ],
    },
    HealthRuleSystem: {
      name: "HealthRuleSystem",
      openAccess: false,
      accessList: ["WorldMoveEventSystem", "WorldBuildEventSystem", "WorldMineEventSystem", "WorldActivateEventSystem"],
    },
  },
  modules: [
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("Metadata")],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("Mass")],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("Energy")],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("Velocity")],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("Health")],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("Stamina")],
    },
  ],
});
