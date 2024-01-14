import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  enums: {
    ElementType: ["None", "Fire", "Water", "Grass"],
  },
  tables: {
    MonumentLikes: {
      keySchema: {
        user: "address",
      },
      schema: {
        likes: "uint256",
      },
    },
    MonumentsLeaderboard: {
      keySchema: {
        // claimed area lower southwest coord
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        length: "uint32",
        width: "uint32",
        height: "uint32",
        rank: "uint256",
        totalLikes: "uint256",
        owner: "address",
        agentObjectEntityId: "bytes32",
        likedBy: "address[]",
      },
    },
    MonumentBounties: {
      keySchema: {
        bountyId: "bytes32",
      },
      schema: {
        creator: "address",
        bountyAmount: "uint256",
        claimedBy: "address",
        objectTypeIds: "bytes32[]",
        relativePositions: "bytes", // VoxelCoord[], the relative position for each object in the monument
        name: "string",
        description: "string",
      },
    },
    CreationRegistry: {
      keySchema: {
        creationId: "bytes32",
      },
      schema: {
        numObjects: "uint32", // The total number of voxels in this creation (including the voxels in the base creations). This value is really important to prevent extra computation when determining the voxels in base creations
        objectTypeIds: "bytes32[]",
        relativePositions: "bytes", // VoxelCoord[], the relative position for each object in the creation
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
    CreatureLeaderboard: {
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        rank: "uint256",
      },
    },
    FarmLeaderboard: {
      keySchema: {
        // ShardCoords
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        rank: "uint256",
        totalProduction: "uint256",
        farmerObjectEntityId: "bytes32",
      },
    },
    ClaimedShard: {
      keySchema: {
        agentObjectEntityId: "bytes32",
      },
      schema: {
        claimedShard: "bytes", // VoxelCoord
      },
    },
    FarmFactionsLeaderboard: {
      keySchema: {
        // ShardCoords
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        rank: "uint256",
        totalProduction: "uint256",
        farmerObjectEntityId: "bytes32",
        faction: "ElementType",
        isDisqualified: "bool",
      },
    },
    CreatureFactionsLeaderboard: {
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        rank: "uint256",
        isDisqualified: "bool",
      },
    },
    FarmDeliveryLeaderboard: {
      keySchema: {
        // ShardCoords
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        totalPoints: "uint256",
        numDeliveries: "uint256",
        agentObjectEntityId: "bytes32",
      },
    },
    OriginatingChunk: {
      keySchema: {
        objectEntityId: "bytes32",
      },
      schema: {
        x: "int32",
        y: "int32",
        z: "int32",
      },
    },
  },
  systems: {
    MonumentBountiesSystem: {
      name: "MTBountiesSystem",
      openAccess: true,
      registerAsRoot: true,
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
      args: [resolveTableId("CreatureLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("FarmLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("FarmFactionsLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("CreatureFactionsLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("MonumentsLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("MonumentBounties")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("FarmDeliveryLeaderboard")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("OriginatingChunk")],
    },
    {
      name: "KeysWithValueModule",
      root: true,
      args: [resolveTableId("OriginatingChunk")],
    },
  ],
});
