import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  enums: {},
  tables: {
    MonumentToken: {
      keySchema: {
        user: "address",
      },
      schema: {
        tokens: "uint256",
      },
    },
    MonumentClaimedArea: {
      keySchema: {
        // lower southwest coord
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        length: "uint32",
        width: "uint32",
        height: "uint32",
        owner: "address",
        agentObjectEntityId: "bytes32",
        displayName: "string",
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
        claimedAreaX: "int32", // VoxelCoord
        claimedAreaY: "int32", // VoxelCoord
        claimedAreaZ: "int32", // VoxelCoord
        objectTypeIds: "bytes32[]",
        relativePositions: "bytes", // VoxelCoord[], the relative position for each object in the monument
        mintedBy: "address[]",
        name: "string",
        description: "string",
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
      args: [resolveTableId("MonumentClaimedArea")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("MonumentBounties")],
    },
  ],
});
