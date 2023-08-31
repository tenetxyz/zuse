import { MUDCoreUserConfig, resolveTableId } from "@latticexyz/config";
import { mudConfig } from "@latticexyz/world/register";
import { ExtractUserTypes, StringForUnion } from "@latticexyz/common/type-utils";
import { MUDUserConfig, TableConfig } from "@latticexyz/store/config";
import { ExpandMUDUserConfig } from "@latticexyz/store/register";

const LAYER_TABLES: Record<string, TableConfig> = {
  CAEntityMapping: {
    registerAsRoot: true,
    keySchema: {
      callerAddress: "address",
      entity: "bytes32",
    },
    schema: {
      caEntity: "bytes32",
    },
  },
  CAEntityReverseMapping: {
    registerAsRoot: true,
    keySchema: {
      caEntity: "bytes32",
    },
    schema: {
      callerAddress: "address",
      entity: "bytes32",
    },
  },
  CAPosition: {
    registerAsRoot: true,
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
    registerAsRoot: true,
    keySchema: {
      callerAddress: "address",
      entity: "bytes32",
    },
    schema: {
      voxelTypeId: "bytes32",
      voxelVariantId: "bytes32",
    },
  },
  CAMind: {
    registerAsRoot: true,
    keySchema: {
      caEntity: "bytes32",
    },
    schema: {
      voxelTypeId: "bytes32",
      mindSelector: "bytes4",
    },
  },
};

const LAYER_MODULES = [
  {
    name: "UniqueEntityModule",
    root: true,
    args: [],
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
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("CAVoxelType")],
  },
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("CAEntityMapping")],
  },
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("CAEntityReverseMapping")],
  },
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("CAMind")],
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
 for (const tableName of Object.keys(LAYER_TABLES)) {
   if (existingTableNames.has(tableName)) {
     // TODO: Support overriding tables
     throw new Error(`Table ${tableName} already exists`);
   }
   const table = LAYER_TABLES[tableName];
   config.tables[tableName] = table;
 }

 // add layer Modules
 // TODO: Add check on duplicates
 config.modules = config.modules.concat(LAYER_MODULES);

  return mudConfig(config) as any;
}
