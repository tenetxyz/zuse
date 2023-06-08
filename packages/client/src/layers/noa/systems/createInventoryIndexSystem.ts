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
import { computedToStream } from "@latticexyz/utils";
import { switchMap } from "rxjs";
import { NetworkLayer } from "../../network";
import { NoaLayer } from "../types";
import { to64CharAddress } from "../../../utils/entity";

export function createInventoryIndexSystem(
  network: NetworkLayer,
  context: NoaLayer
) {
  const {
    contractComponents: { OwnedBy, Item },
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
          [HasValue(OwnedBy, { value: to64CharAddress(address) }), Has(Item)],
          {
            runOnInit: true,
          }
        ).update$
    )
  );

  // TODO: I couldn't get this function to work, as the itemsIOwn query is empty when this first runs
  const removeInventoryIndexesForItemsWeNoLongerOwn = () => {
    const itemsIOwn = runQuery([
      HasValue(OwnedBy, { value: to64CharAddress(connectedAddress.get()) }),
      Has(Item),
    ]);
    const itemTypesIOwn = new Set(
      Array.from(itemsIOwn).map(
        (item) => getComponentValue(Item, item)?.value as Entity
      )
    );
    for (const itemType of InventoryIndex.values.value.keys()) {
      if (!itemTypesIOwn.has(itemType.description as Entity)) {
        removeComponent(InventoryIndex, itemType.description as Entity);
      }
    }
  };
  // removeInventoryIndexesForItemsWeNoLongerOwn();

  // this function assigns inventory indexes to items we own
  // whenever we get/lose an item, this function is run
  defineRxSystem(world, update$, (update) => {
    if (!update.value[0]) {
      // the block just got removed, so don't assign an inventory index for it
      return;
    }
    const blockId = getComponentValue(Item, update.entity)?.value as Entity;
    // console.log(blockId);

    if (blockId == null) return;

    // Assign the first free inventory index
    if (!hasComponent(InventoryIndex, blockId)) {
      const values = [...InventoryIndex.values.value.values()]; // lol
      let i = 0;
      while (values.includes(i)) i++;
      setComponent(InventoryIndex, blockId, { value: i });
    }
  });
}
