import {
  defineQuery,
  HasValue,
  Has,
  getComponentValue,
  Entity,
  hasComponent,
  setComponent,
  defineRxSystem,
  removeComponent,
  runQuery,
  Component,
  Type,
} from "@latticexyz/recs";
import { awaitStreamValue, computedToStream } from "@latticexyz/utils";
import { switchMap } from "rxjs";
import { NetworkLayer } from "../../network";
import {
  NoaLayer,
  voxelTypeToVoxelTypeBaseKey,
  voxelTypeBaseKeyToEntity,
  voxelTypeToVoxelTypeBaseKeyString as voxelTypeToVoxelTypeBaseKeyStr,
} from "../types";
import { to64CharAddress } from "../../../utils/entity";
import { SyncState } from "@latticexyz/network";
import { IComputedValue } from "mobx";

// returns a set of entityKeys: namespace:voxelType
export const getItemTypesIOwn = (
  OwnedBy: Component<{
    value: Type.String;
  }>,
  VoxelType: Component<{
    voxelTypeNamespace: Type.String;
    voxelTypeId: Type.String;
    voxelVariantNamespace: Type.String;
    voxelVariantId: Type.String;
  }>,
  connectedAddress: IComputedValue<string | undefined>
): Set<string> => {
  const itemsIOwn = runQuery([HasValue(OwnedBy, { value: to64CharAddress(connectedAddress.get()) })]);
  return new Set(
    Array.from(itemsIOwn)
      .map((item) => {
        const voxelType = getComponentValue(
          VoxelType,
          ("0x0000000000000000000000000000000000000000000000000000000000000001:" + item) as Entity
        );
        if (voxelType === undefined) {
          console.warn(`voxelType of item you own is undefined item=${item.toString()}`);
          return "";
        }
        return voxelTypeToVoxelTypeBaseKeyStr(voxelType);
      })
      .filter((item) => item !== "")
  );
};

export function createInventoryIndexSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    components: { LoadingState },
    contractComponents: { OwnedBy, VoxelType },
    network: { connectedAddress },
  } = network;

  const {
    world,
    components: { InventoryIndex },
  } = context;

  const connectedAddress$ = computedToStream(connectedAddress);

  const update$ = connectedAddress$.pipe(
    switchMap(
      (address) =>
        defineQuery([HasValue(OwnedBy, { value: to64CharAddress(address) })], {
          runOnInit: true,
        }).update$
    )
  );
  const removeInventoryIndexesForItemsWeNoLongerOwn = () => {
    const itemTypesIOwn = getItemTypesIOwn(OwnedBy, VoxelType, connectedAddress);
    for (const itemType of InventoryIndex.values.value.keys()) {
      const voxelTypeBaseKeyStr = itemType.description as string;
      if (!itemTypesIOwn.has(voxelTypeBaseKeyStr)) {
        removeComponent(InventoryIndex, itemType.description as Entity);
      }
    }
  };

  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(
    removeInventoryIndexesForItemsWeNoLongerOwn
  );

  // this function assigns inventory indexes to voxeltypes we own
  // whenever we get/lose a voxeltype, this function is run
  defineRxSystem(world, update$, (update) => {
    if (!update.value[0]) {
      // the voxel just got removed, so don't assign an inventory index for it
      return;
    }
    const voxelType = getComponentValue(
      VoxelType,
      ("0x0000000000000000000000000000000000000000000000000000000000000001:" + update.entity) as Entity
    );
    console.log("over here");
    console.log(voxelType);

    if (voxelType === undefined) return;
    const voxelTypeBaseKey = voxelTypeToVoxelTypeBaseKeyStr(voxelType) as Entity;

    // Assign the first free inventory index
    if (!hasComponent(InventoryIndex, voxelTypeBaseKey)) {
      const freeInventoryIndex = firstFreeInventoryIndex(InventoryIndex, 0);
      setComponent(InventoryIndex, voxelTypeBaseKey, { value: freeInventoryIndex });
    }
  });
}

export const firstFreeInventoryIndex = (InventoryIndex: any, startingIndex: number): number => {
  let i = startingIndex;
  const values = [...InventoryIndex.values.value.values()]; // lol
  while (values.includes(i)) i++;
  return i;
};
