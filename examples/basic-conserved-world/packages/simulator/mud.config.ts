import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  enums: {
    ObjectType: ["None", "Fire", "Water", "Grass"],
    SimTable: ["None", "Mass", "Energy", "Velocity", "Health", "Stamina", "Object", "Action"],
    ValueType: ["Uint256", "ObjectType"],
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
        actionEntity: "bytes",
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
  },
  systems: {
    EnergyHelperSystem: {
      name: "EnergyHelperSyst",
      openAccess: false,
      accessList: ["MassSystem", "EnergySystem", "VelocitySystem", "ActionSystem"],
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
  ],
});
