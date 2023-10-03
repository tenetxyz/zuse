import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  tables: {
    BodyPhysics: {
      keySchema: {
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        mass: "uint256",
        energy: "uint256",
        lastUpdateBlock: "uint256", // TODO: Rename to lastUpdateCacheBlock?
        velocity: "bytes", // VoxelCoord, 3D vector
      },
    },
    TerrainProperties: {
      keySchema: {
        x: "int32",
        y: "int32",
        z: "int32",
      },
      schema: {
        bucketIndex: "uint8",
      },
    },
    VoxelTypeProperties: {
      keySchema: {
        voxelTypeId: "bytes32",
      },
      schema: {
        mass: "uint256",
      },
    },
  },
  systems: {},
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("BodyPhysics")],
    },
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("TerrainProperties")],
    },
  ],
});
