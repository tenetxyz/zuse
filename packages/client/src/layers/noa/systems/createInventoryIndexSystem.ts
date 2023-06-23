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
} from "@latticexyz/recs";
import { awaitStreamValue, computedToStream } from "@latticexyz/utils";
import { switchMap } from "rxjs";
import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { to64CharAddress } from "../../../utils/entity";
import { SyncState } from "@latticexyz/network";
import { IComputedValue } from "mobx";

export const getItemTypesIOwn = (
  OwnedBy: any,
  VoxelType: any,
  connectedAddress: IComputedValue<string | undefined>
): Set<Entity> => {
  const itemsIOwn = runQuery([
    HasValue(OwnedBy, { value: to64CharAddress(connectedAddress.get()) }),
    Has(VoxelType),
  ]);
  return new Set(
    Array.from(itemsIOwn).map(
      (item) => getComponentValue(VoxelType, item)?.value as Entity
    )
  );
};

export function createInventoryIndexSystem(
  network: NetworkLayer,
  context: NoaLayer
) {
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
        defineQuery(
          [
            HasValue(OwnedBy, { value: to64CharAddress(address) }),
            Has(VoxelType),
          ],
          {
            runOnInit: true,
          }
        ).update$
    )
  );
  const removeInventoryIndexesForItemsWeNoLongerOwn = () => {
    const itemTypesIOwn = getItemTypesIOwn(
      OwnedBy,
      VoxelType,
      connectedAddress
    );
    for (const itemType of InventoryIndex.values.value.keys()) {
      // since itemType is a symbol, we use itemType.description to get the bytes32 itemType id as a string type
      if (!itemTypesIOwn.has(itemType.description as Entity)) {
        removeComponent(InventoryIndex, itemType.description as Entity);
      }
    }
  };

  awaitStreamValue(
    LoadingState.update$,
    ({ value }) => value[0]?.state === SyncState.LIVE
  ).then(removeInventoryIndexesForItemsWeNoLongerOwn);

  // this function assigns inventory indexes to voxeltypes we own
  // whenever we get/lose a voxeltype, this function is run
  defineRxSystem(world, update$, (update) => {
    if (!update.value[0]) {
      // the voxel just got removed, so don't assign an inventory index for it
      return;
    }
    const voxelType = getComponentValue(VoxelType, update.entity)
      ?.value as Entity;

    if (voxelType == null) return;

    // Assign the first free inventory index
    if (!hasComponent(InventoryIndex, voxelType)) {
      const values = [...InventoryIndex.values.value.values()]; // lol
      let i = 0;
      while (values.includes(i)) i++;
      setComponent(InventoryIndex, voxelType, { value: i });
    }
  });
}
