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
    Temperature: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        temperature: "uint256",
        lastUpdateBlock: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    TemperatureAtTime: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        temperature: "uint256",
        lastUpdateBlock: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Generator: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        genRate: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        sources: "bytes32[]",
        sourceDirections: "bytes", // BlockDirection[]
      },
    },
    PowerWire: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        source: "bytes32",
        destination: "bytes32",
        transferRate: "uint256",
        maxTransferRate: "uint256",
        sourceDirection: "BlockDirection",
        destinationDirection: "BlockDirection",
        lastUpdateBlock: "uint256",
        isBroken: "bool",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Storage: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        maxStorage: "uint256",
        energyStored: "uint256",
        inRate: "uint256",
        outRate: "uint256",
        source: "bytes32",
        destination: "bytes32",
        sourceDirection: "BlockDirection",
        destinationDirection: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        inBlockHeightUpdate: "bytes", // BlockHeightUpdate
        outBlockHeightUpdate: "bytes", // BlockHeightUpdate
      },
    },
    Consumer: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        source: "bytes32",
        sourceDirection: "BlockDirection",
        inRate: "uint256",
        lastUpdateBlock: "uint256",
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
    // TODO: Add the rest of the systems (or really figure out better way to do this)
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
