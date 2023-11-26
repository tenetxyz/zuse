import { MUDCoreUserConfig, resolveTableId } from "@latticexyz/config";
import { mudConfig } from "@latticexyz/world/register";
import { ExtractUserTypes, StringForUnion } from "@latticexyz/common/type-utils";
import { MUDUserConfig, TableConfig } from "@latticexyz/store/config";
import { ExpandMUDUserConfig } from "@latticexyz/store/register";

const WORLD_TABLES: Record<string, TableConfig> = {
  ObjectType: {
    registerAsRoot: true,
    keySchema: {
      entityId: "bytes32",
    },
    schema: {
      objectTypeId: "bytes32",
    },
  },
  Position: {
    registerAsRoot: true,
    keySchema: {
      entityId: "bytes32",
    },
    schema: {
      x: "int32",
      y: "int32",
      z: "int32",
    },
  },
  ObjectEntity: {
    registerAsRoot: true,
    keySchema: {
      entityId: "bytes32",
    },
    schema: {
      objectEntityId: "bytes32",
    },
  },
  // Note: We have this table due to running on the EVM,
  // but we can use the equivalent of a public/private key once Zuse is its own computer
  OwnedBy: {
    registerAsRoot: true,
    keySchema: {
      objectEntityId: "bytes32",
    },
    schema: {
      user: "address",
    },
  },
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
    args: [resolveTableId("ObjectType")],
  },
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("Position")],
  },
  {
    name: "KeysWithValueModule",
    root: true,
    args: [resolveTableId("Position")],
  },
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("ObjectEntity")],
  },
  {
    name: "KeysWithValueModule",
    root: true,
    args: [resolveTableId("ObjectEntity")],
  },
  {
    name: "KeysInTableModule",
    root: true,
    args: [resolveTableId("OwnedBy")],
  },
];

const WORLD_SYSTEMS = {
  BuildSystem: {
    name: "BuildSystem",
    openAccess: true,
    registerAsRoot: true,
  },
  MineSystem: {
    name: "MineSystem",
    openAccess: true,
    registerAsRoot: true,
  },
  MoveSystem: {
    name: "MoveSystem",
    openAccess: true,
    registerAsRoot: true,
  },
  ActivateSystem: {
    name: "ActivateSystem",
    openAccess: true,
    registerAsRoot: true,
  },
  TerrainSystem: {
    name: "TerrainSystem",
    openAccess: true,
    registerAsRoot: true,
  },
  EventApprovalsSystem: {
    name: "EventApprovalSys",
    openAccess: false,
    accessList: ["BuildSystem", "MineSystem", "MoveSystem", "ActivateSystem"],
    registerAsRoot: true,
  },
  ObjectSystem: {
    name: "ObjectSystem",
    openAccess: false,
    accessList: ["BuildSystem", "MineSystem", "MoveSystem", "ActivateSystem"],
    registerAsRoot: true,
  },
  ObjectInteractionSystem: {
    name: "ObjInteracSystem",
    openAccess: false,
    accessList: ["BuildSystem", "MineSystem", "MoveSystem", "ActivateSystem"],
    registerAsRoot: true,
  },
  ActionSystem: {
    name: "ActionSystem",
    openAccess: false,
    accessList: ["ObjectInteractionSystem"],
    registerAsRoot: true,
  },
};

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
  config.systems = config.systems || {};
  const existingSystemNames = new Set(Object.keys(config.systems));
  for (const systemName of Object.keys(WORLD_SYSTEMS)) {
    if (existingSystemNames.has(systemName)) {
      // TODO: Support overriding systems
      throw new Error(`System ${systemName} already exists`);
    }
    const system = WORLD_SYSTEMS[systemName];
    config.systems[systemName] = system;
  }

  // add layer Modules
  // TODO: Add check on duplicates
  config.modules = config.modules.concat(WORLD_MODULES);

  return mudConfig(config) as any;
}
