import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
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
        activateSelector: "bytes4",
        interactionSelector: "bytes4",
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
  },
  systems: {
    AirVoxelSystem: {
      name: "AirVoxelSystem",
      openAccess: false,
      accessList: ["CASystem"],
    },
    RoadVoxelSystem: {
      name: "RoadVoxelSystem",
      openAccess: false,
      accessList: ["CASystem"],
    },
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
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("CAVoxelType")],
    },
  ],
});
