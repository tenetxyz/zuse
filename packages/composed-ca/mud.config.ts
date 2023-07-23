import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  tables: {
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
    CAVoxelTypeDefs: {
      keySchema: {
        voxelTypeId: "bytes32",
      },
      schema: {
        voxelTypeIds: "bytes32[]",
        voxelRelativePositions: "bytes", // VoxelCoord[]
      },
    },
  },
  modules: [
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
      args: [resolveTableId("CAVoxelTypeDefs")],
    },
  ],
});
