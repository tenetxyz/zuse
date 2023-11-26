import { MUDCoreUserConfig, resolveTableId } from "@latticexyz/config";
import { mudConfig } from "@latticexyz/world/register";
import { ExtractUserTypes, StringForUnion } from "@latticexyz/common/type-utils";
import { MUDUserConfig, TableConfig } from "@latticexyz/store/config";
import { ExpandMUDUserConfig } from "@latticexyz/store/register";

const SIMULATOR_TABLES: Record<string, TableConfig> = {
  SimAction: {
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
};

const SIMULATOR_MODULES = [];

export function tenetMudConfig<
  T extends MUDCoreUserConfig,
  // (`never` is overridden by inference, so only the defined enums can be used by default)
  EnumNames extends StringForUnion = never,
  StaticUserTypes extends ExtractUserTypes<EnumNames> = ExtractUserTypes<EnumNames>
>(config: MUDUserConfig<T, EnumNames, StaticUserTypes>): ExpandMUDUserConfig<T> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  // add layer Tables
  const existingTableNames = new Set(Object.keys(config.tables));
  for (const tableName of Object.keys(SIMULATOR_TABLES)) {
    if (existingTableNames.has(tableName)) {
      // TODO: Support overriding tables
      throw new Error(`Table ${tableName} already exists`);
    }
    const table = SIMULATOR_TABLES[tableName];
    config.tables[tableName] = table;
  }

  // add layer Modules
  // TODO: Add check on duplicates
  config.modules = config.modules.concat(SIMULATOR_MODULES);

  return mudConfig(config) as any;
}
