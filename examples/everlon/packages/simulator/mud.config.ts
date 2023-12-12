import { tenetMudConfig } from "@tenetxyz/base-simulator";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  enums: {
    ElementType: ["None", "Fire", "Water", "Grass"],
    SimTable: [
      "None",
      "Mass",
      "Energy",
      "Velocity",
      "Health",
      "Stamina",
      "Element",
      "CombatMove",
      "Nutrients",
      "Nitrogen",
      "Phosphorus",
      "Potassium",
      "Elixir",
      "Protein",
    ],
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
    Element: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        elementType: "ElementType",
      },
    },
    CombatMove: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        moveType: "ElementType",
        stamina: "uint256",
        toObjectEntityId: "bytes32",
      },
    },
    Nutrients: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        nutrients: "uint256",
      },
    },
    Nitrogen: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        nitrogen: "uint256",
      },
    },
    Phosphorus: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        phosphorus: "uint256",
      },
    },
    Potassium: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        potassium: "uint256",
      },
    },
    Elixir: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        elixir: "uint256",
      },
    },
    Protein: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        protein: "uint256",
      },
    },
    Temperature: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        temperature: "uint256",
      },
    },
  },
  systems: {
    // Rules should only be called by world systems
    FluxEnergyRuleSystem: {
      name: "FluxEnergyRuleSy",
      openAccess: false,
      accessList: [
        "VelocityRuleSystem",
        "MassConstraintSystem",
        "StaminaVelocityConstraintSystem",
        "NutrientsConstraintSystem",
        "EnergyNutrientsConstraintSystem",
        "NutrientsElixirConstraintSystem",
        "NutrientsProteinConstraintSystem",
        "CombatMoveRuleSystem",
        "StaminaCombatMoveConstraintSystem",
        "TemperatureConstraintSystem",
        "EnergyTemperatureConstraintSystem",
        "TemperatureRuleSystem",
      ],
    },
    CollisionRuleSystem: {
      name: "CollisionRuleSys",
      openAccess: false,
      accessList: ["WorldMoveEventSystem"],
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
    CombatMoveRuleSystem: {
      name: "CombatMoveRuleSy",
      openAccess: false,
      accessList: ["WorldMoveEventSystem", "WorldBuildEventSystem", "WorldMineEventSystem", "WorldActivateEventSystem"],
    },
    TemperatureRuleSystem: {
      name: "TemperatureRuleS",
      openAccess: false,
      accessList: [
        "WorldMoveEventSystem",
        "WorldBuildEventSystem",
        "WorldMineEventSystem",
        "WorldActivateEventSystem",
        "TemperatureConstraintSystem",
        "EnergyTemperatureConstraintSystem",
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
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Metadata")],
    },
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
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Health")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Stamina")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Element")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("CombatMove")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Nutrients")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Nitrogen")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Phosphorus")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Potassium")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Elixir")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Protein")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Temperature")],
    },
  ],
});
