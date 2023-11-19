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
    CreationRegistry: {
      keySchema: {
        creationId: "bytes32",
      },
      schema: {
        numObjects: "uint32", // The total number of voxels in this creation (including the voxels in the base creations). This value is really important to prevent extra computation when determining the voxels in base creations
        objectTypes: "bytes32[]",
        relativePositions: "bytes", // VoxelCoord[], the relative position for each voxel in the creation
        baseCreations: "bytes", // it is called "base" creation - cause of "base class" in c++. To make composable creations work, root creations are comprised of these base creations.
        metadata: "bytes", // CreationMetadata
        // Note: can't add more dynamic fields cause rn we can only have at most 5 dynamic fields: https://github.com/tenetxyz/mud/blob/main/packages/store/src/Schema.sol#L20
      },
    },
    ClassifierRegistry: {
      keySchema: {
        classifierId: "bytes32",
      },
      schema: {
        creator: "address",
        classifySelector: "bytes4", // the function that will be called when the user submits to the classifier
        name: "string",
        description: "string",
        selectorInterface: "bytes", // InterfaceVoxel[] the interface that the classifier will use
        classificationResultTableName: "string", // needed so the client can know which table to query for the classification result
      },
    },
  },
  systems: {
    CreationRegistrySystem: {
      name: "CreationRegSys",
      openAccess: true,
    },
    ClassifierRegistrySystem: {
      name: "ClassifierRegSys",
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
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("ObjectTypeRegistry")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("CreationRegistry")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("ClassifierRegistry")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("DecisionRuleRegistry")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("MindRegistry")],
    },
  ],
});
