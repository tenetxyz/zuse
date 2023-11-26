import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  enums: {
    ObjectType: ["None", "Fire", "Water", "Grass"],
    SimTable: [
      "None",
      "Mass",
      "Energy",
      "Velocity",
      "Health",
      "Stamina",
      "Object",
      "Action",
      "Nutrients",
      "Nitrogen",
      "Phosphorous",
      "Potassium",
      "Elixir",
      "Protein",
    ],
    ValueType: ["Int256", "ObjectType"],
  },
  tables: {
    SimSelectors: {
      keySchema: {
        senderTable: "SimTable",
        receiverTable: "SimTable",
      },
      schema: {
        selector: "bytes4",
        senderValueType: "ValueType",
        receiverValueType: "ValueType",
      },
    },
    Metadata: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        lastInteractionBlock: "uint256",
      },
    },
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
        lastUpdateBlock: "uint256",
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
    Object: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        objectType: "ObjectType",
      },
    },
    Action: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        actionType: "ObjectType",
        stamina: "uint256",
        actionEntity: "bytes", // VoxelEntity
      },
    },
    Nutrients: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        nutrients: "uint256",
      },
    },
    Nitrogen: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        nitrogen: "uint256",
      },
    },
    Phosphorous: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        phosphorous: "uint256",
      },
    },
    Potassium: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        potassium: "uint256",
      },
    },
    Elixir: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        elixir: "uint256",
      },
    },
    Protein: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        protein: "uint256",
      },
    },
    Temperature: {
      keySchema: {
        callerAddress: "address",
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        temperature: "uint256",
      },
    },
  },
  systems: {
    FluxSystem: {
      name: "FluxSystem",
      openAccess: false,
      accessList: ["MassSystem", "EnergySystem", "VelocitySystem", "ActionSystem", "NutrientsSystem"],
    },
    CollisionSystem: {
      name: "CollisionSystem",
      openAccess: false,
      accessList: ["VelocitySystem"],
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
      args: [resolveTableId("Object")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Action")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("Action")],
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
      args: [resolveTableId("Phosphorous")],
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
