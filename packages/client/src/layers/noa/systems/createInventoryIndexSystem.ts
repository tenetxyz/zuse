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
import { NoaLayer, VoxelBaseTypeId } from "../types";
import { to64CharAddress } from "../../../utils/entity";
import { SyncState } from "@latticexyz/network";
import { IComputedValue } from "mobx";

export const getItemTypesIOwn = (
  OwnedBy: Component<{
    value: Type.String;
  }>,
  VoxelType: Component<{
    voxelTypeId: Type.String;
    voxelVariantId: Type.String;
  }>,
  connectedAddress: IComputedValue<string | undefined>
): Set<VoxelBaseTypeId> => {
  const itemsIOwn = runQuery([HasValue(OwnedBy, { value: to64CharAddress(connectedAddress.get()) }), Has(VoxelType)]);
  return new Set(
    Array.from(itemsIOwn)
      .map((item) => {
        const voxelType = getComponentValue(VoxelType, item);
        if (voxelType === undefined) {
          console.warn(`voxelType of item you own is undefined item=${item.toString()}`);
          return "";
        }
        return voxelType.voxelTypeId;
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
        defineQuery([HasValue(OwnedBy, { value: to64CharAddress(address) }), Has(VoxelType)], {
          runOnInit: true,
        }).update$
    )
  );
  const removeInventoryIndexesForItemsWeNoLongerOwn = () => {
    const itemTypesIOwn = getItemTypesIOwn(OwnedBy, VoxelType, connectedAddress);
    for (const itemType of InventoryIndex.values.value.keys()) {
      const voxelBaseTypeIdStr = itemType.description as string;
      if (!itemTypesIOwn.has(voxelBaseTypeIdStr)) {
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
    const voxelType = getComponentValue(VoxelType, update.entity);

    if (voxelType === undefined) return;
    const voxelBaseTypeId = voxelType.voxelTypeId as Entity;

    // Assign the first free inventory index
    if (!hasComponent(InventoryIndex, voxelBaseTypeId)) {
      const freeInventoryIndex = firstFreeInventoryIndex(InventoryIndex, 0);
      setComponent(InventoryIndex, voxelBaseTypeId, { value: freeInventoryIndex });
    }
  });
}

export const firstFreeInventoryIndex = (InventoryIndex: any, startingIndex: number): number => {
  let i = startingIndex;
  const values = [...InventoryIndex.values.value.values()]; // lol
  while (values.includes(i)) i++;
  return i;
};
