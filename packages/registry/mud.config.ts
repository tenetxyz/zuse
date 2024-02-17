import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  tables: {
    ObjectTypeRegistry: {
      keySchema: {
        objectTypeId: "bytes32",
      },
      schema: {
        creator: "address",
        contractAddress: "address",
        enterWorldSelector: "bytes4",
        exitWorldSelector: "bytes4",
        eventHandlerSelector: "bytes4",
        neighbourEventHandlerSelector: "bytes4",
        name: "string",
        description: "string",
      },
    },
    DecisionRuleRegistry: {
      keySchema: {
        srcObjectTypeId: "bytes32",
        targetObjectTypeId: "bytes32",
      },
      schema: {
        decisionRules: "bytes", // DecisionRule[]
      },
    },
    MindRegistry: {
      keySchema: {
        objectTypeId: "bytes32",
      },
      schema: {
        minds: "bytes", // Mind[]
      },
    },
  },
  systems: {
    DecisionRuleRegistrySystem: {
      name: "DecisionRuleRegS",
      openAccess: true,
    },
  },
  modules: [
    {
      name: "UniqueEntityModule",
      root: true,
      args: [],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("ObjectTypeRegistry")],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("DecisionRuleRegistry")],
    },
    {
      name: "HasKeysModule",
      root: true,
      args: [resolveTableId("MindRegistry")],
    },
  ],
});
