import storeConfig from "@tenetxyz/contracts/mud.config";
import { createDatabaseClient } from "@latticexyz/store-cache";

export type TenetStoreCache = ReturnType<typeof createDatabaseClient<typeof storeConfig>>; // TODO: move this to live store cache
export type LiveStoreCache = ReturnType<typeof getLiveStoreCache>;

// a liveStoreCache is a map that is constantly updated when new updates from the storeCache arrives
export const getLiveStoreCache = (storeCache: TenetStoreCache) => {
  const positionMap = new Map<string, any>();

  // Note: this method of generating types won't work if the mud config doesn't specify a keyschema. But since this is only used for
  // tables with multi-keys it should be fine
  const positionKey = (positionKeyObj: any) => {
    return `${positionKeyObj.entity}:${positionKeyObj.scale}`;
  };

  storeCache.tables.Position.subscribe((updateArray) => {
    for (const update of updateArray) {
      for (const setEvent of update.set) {
        positionMap.set(positionKey(setEvent.key), setEvent.value);
      }
      for (const removeEvent of update.remove) {
        positionMap.delete(positionKey(removeEvent.key));
      }
    }
  });

  const getPosition = (key: any) => {
    return positionMap.get(positionKey(key));
  };

  const Position = {
    theMap: positionMap,
    get: getPosition,
  };

  // const voxelTypeMap = new Map<string, typeof VoxelTypeTable.schema>(); // this isnt' the right way to get the type since it's the schema of our json, NOT the actual generated schema
  const voxelTypeMap = new Map<string, any>();

  // Note: this method of generating types won't work if the mud config doesn't specify a keyschema. But since this is only used for
  // tables with multi-keys it should be fine
  const voxelTypeKey = (voxelTypeKeyObj: any) => {
    return `${voxelTypeKeyObj.entity}:${voxelTypeKeyObj.scale}`;
  };

  storeCache.tables.VoxelType.subscribe((updateArray) => {
    for (const update of updateArray) {
      for (const setEvent of update.set) {
        voxelTypeMap.set(voxelTypeKey(setEvent.key), setEvent.value);
      }
      for (const removeEvent of update.remove) {
        voxelTypeMap.delete(voxelTypeKey(removeEvent.key));
      }
    }
  });

  const getVoxelType = (key: any) => {
    return voxelTypeMap.get(voxelTypeKey(key));
  };

  const VoxelType = {
    theMap: voxelTypeMap,
    get: getVoxelType,
  };

  return { Position, VoxelType };
};
