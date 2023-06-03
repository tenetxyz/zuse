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

export function createInventoryIndexSystem(network: NetworkLayer, context: NoaLayer) {
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
    switchMap((address) =>
          defineQuery([HasValue(OwnedBy, { value: to64CharAddress(address) }), Has(Item)], {
          runOnInit: true,
        }).update$
    )
  );

  defineRxSystem(world, update$, (update) => {
    // console.log("inventory update called");
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
