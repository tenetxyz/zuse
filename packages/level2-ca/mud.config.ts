import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  enums: {
    BlockDirection: ["None", "North", "South", "East", "West", "NorthEast", "NorthWest", "SouthEast", "SouthWest"],
  },
  tables: {
    CAVoxelConfig: {
      // TODO: Should this be in registry?
      keySchema: {
        voxelTypeId: "bytes32",
      },
      schema: {
        enterWorldSelector: "bytes4",
        exitWorldSelector: "bytes4",
        voxelVariantSelector: "bytes4",
      },
    },
    CAVoxelInteractionConfig: {
      keySchema: {},
      schema: {
        interactionSelectors: "bytes4[]",
      },
    },
    CAPosition: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        // VoxelCoord is removed in MUD2, so we need to manually specify x,y,z
        x: "int32",
        y: "int32",
        z: "int32",
      },
    },
    CAVoxelType: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        voxelTypeId: "bytes32",
        voxelVariantId: "bytes32",
      },
    },
    // Specific CA tables
    Signal: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        isActive: "bool",
        direction: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    SignalSource: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        isNatural: "bool",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Powered: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        isActive: "bool",
        direction: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    InvertedSignal: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        isActive: "bool",
        direction: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
  },
  systems: {
    AirVoxelSystem: {
      name: "AirVoxelSystem",
      openAccess: false,
      accessList: ["CASystem"],
    },
    DirtVoxelSystem: {
      name: "DirtVoxelSystem",
      openAccess: false,
      accessList: ["CASystem"],
    },
    GrassVoxelSystem: {
      name: "GrassVoxelSystem",
      openAccess: false,
      accessList: ["CASystem"],
    },
    BedrockVoxelSystem: {
      name: "BedrockVoxelSys",
      openAccess: false,
      accessList: ["CASystem"],
    },
    WireVoxelSystem: {
      name: "WireVoxelSystem",
      openAccess: false,
      accessList: ["CASystem"],
    },
    WireSystem: {
      name: "WireSystem",
      openAccess: false,
      accessList: ["CASystem"],
    },
    SignalVoxelSystem: {
      name: "SignalVoxelSys",
      openAccess: false,
      accessList: ["CASystem"],
    },
    SignalSourceVoxelSystem: {
      name: "SignalSourceVoxe",
      openAccess: false,
      accessList: ["CASystem"],
    },
    SignalSystem: {
      name: "SignalSystem",
      openAccess: false,
      accessList: ["CASystem"],
    },
  },
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("CAVoxelConfig")],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("CAPosition")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("CAPosition")],
    },
  ],
});
