import { MUDCoreUserConfig, resolveTableId } from "@latticexyz/config";
import { mudConfig } from "@latticexyz/world/register";
import { ExtractUserTypes, StringForUnion } from "@latticexyz/common/type-utils";
import { MUDUserConfig, TableConfig } from "@latticexyz/store/config";
import { ExpandMUDUserConfig } from "@latticexyz/store/register";

const WORLD_TABLES: Record<string, TableConfig> = {
  WorldConfig: {
    keySchema: {
      voxelTypeId: "bytes32",
    },
    schema: {
      caAddress: "address",
    },
  },
  VoxelType: {
    keySchema: {
      scale: "uint32",
      entity: "bytes32",
    },
    schema: {
      voxelTypeId: "bytes32", // TODO: rename to voxelBaseTypeId
      voxelVariantId: "bytes32",
    },
  },
  Position: {
    keySchema: {
      scale: "uint32",
      entity: "bytes32",
    },
    schema: {
      // VoxelCoord is removed in MUD2, so we need to manually specify x,y,z
      x: "int32",
      y: "int32",
      z: "int32",
    },
  },
  VoxelActivated: {
    keySchema: {
      player: "address",
    },
    schema: {
      scale: "uint32",
      entity: "bytes32",
      message: "string",
    },
    ephemeral: true,
  },
  // tables for spawning
  OfSpawn: {
    // maps a voxel spawned in the world -> the entityId representing its spawn
    keySchema: {
      scale: "uint32",
      entity: "bytes32",
    },
    schema: {
      spawnId: "bytes32",
    },
  },
  Spawn: {
    schema: {
      creationId: "bytes32", // the creation that it's a spawn of
      isModified: "bool", // modified spawns can't be submitted to classifiers
      lowerSouthWestCorner: "bytes", // VoxelCoord
      voxels: "bytes", // the voxel entities that have been spawned
    },
  }
};

const WORLD_MODULES = [
  {
    name: "UniqueEntityModule",
    root: true,
    args: [],
  },
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("Position")],
  },
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("WorldConfig")],
  },
  {
    name: "KeysWithValueModule",
    root: true,
    args: [resolveTableId("Position")],
  },
  {
    name: "KeysWithValueModule",
    root: true,
    args: [resolveTableId("VoxelType")],
  },
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("VoxelType")],
  },
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("Spawn")],
  },
];

export function tenetMudConfig<
  T extends MUDCoreUserConfig,
  // (`never` is overridden by inference, so only the defined enums can be used by default)
  EnumNames extends StringForUnion = never,
  StaticUserTypes extends ExtractUserTypes<EnumNames> = ExtractUserTypes<EnumNames>
>(config: MUDUserConfig<T, EnumNames, StaticUserTypes>): ExpandMUDUserConfig<T> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
 // add layer Tables
 const existingTableNames = new Set(Object.keys(config.tables));
 for (const tableName of Object.keys(WORLD_TABLES)) {
   if (existingTableNames.has(tableName)) {
     // TODO: Support overriding tables
     throw new Error(`Table ${tableName} already exists`);
   }
   const table = WORLD_TABLES[tableName];
   config.tables[tableName] = table;
  }

  // add layer Modules
  // TODO: Add check on duplicates
  config.modules = config.modules.concat(WORLD_MODULES);

  return mudConfig(config) as any;
}
