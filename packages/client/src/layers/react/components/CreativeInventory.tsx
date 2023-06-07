import { Slot } from "./common";
import { Entity, getEntitiesWithValue } from "@latticexyz/recs";
import { Layers } from "../../../types";
import { range } from "@latticexyz/utils";
import styled from "styled-components";
import React from "react";

interface Props {
  layers: Layers;
  moveItems: (number: number) => void;
}
const NUM_COLS = 9;
const NUM_ROWS = 8;

interface Item {
  name: string;
  description: string;
  blockId: Entity;
}

export const CreativeInventory: React.FC<Props> = ({ layers }) => {
  const {
    components: { ItemPrototype },
    api: { giftVoxel },
  } = layers.network;

  const [items, setItems] = React.useState<Item[]>();
  React.useEffect(() => {
    const entities = getEntitiesWithValue(ItemPrototype, { value: true });
    console.log("creative items", entities);
    const unsortedItems = Array.from(entities).map((entity) => {
      return {
        name: entity as string,
        description: "tmp desc",
        blockId: entity,
      };
    });
    setItems(unsortedItems.sort((a, b) => a.name.localeCompare(b.name)));
    // TODO: this function is probably useful later
    // console.log(BlockIdToKey);
  }, [ItemPrototype]);

  const Slots = [...range(NUM_ROWS * NUM_COLS)].map((i) => {
    if (!items || i >= items.length) {
      return <Slot key={"voxel-search-slot" + i} disabled={true} />;
    }
    const item = items[i];
    return (
      <Slot
        key={"slot" + i}
        blockID={item.blockId}
        quantity={undefined} // undefined so no number appears
        onClick={() => giftVoxel(item.blockId)}
        disabled={false} // false, so if you pick up the item, it still shows up in the creative inventory
        selected={false} // you can never select an item in the creative inventory
      />
    );
  });

  // TODO: figure out if this rendering logic is correct
  return (
    <ActionBarWrapper>
      {[...range(NUM_COLS * NUM_ROWS)]
        .map((i) => i + NUM_COLS)
        .map((i) => Slots[i])}
    </ActionBarWrapper>
  );
};

const ActionBarWrapper = styled.div`
  background-color: rgb(0 0 0 / 40%);
  display: grid;
  grid-template-columns: repeat(9, 1fr);
  align-items: center;
  pointer-events: all;
  border: 5px lightgray solid;
  z-index: 10;
  position: relative;
`;
