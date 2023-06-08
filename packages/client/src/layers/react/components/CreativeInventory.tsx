import { Slot } from "./common";
import { Entity, getEntitiesWithValue } from "@latticexyz/recs";
import { Layers } from "../../../types";
import { range } from "@latticexyz/utils";
import styled from "styled-components";
import React, { ChangeEvent, ChangeEventHandler } from "react";
import Fuse from "fuse.js";

interface Props {
  layers: Layers;
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

  const [searchValue, setSearchValue] = React.useState<string>("");
  const [items, setItems] = React.useState<Item[]>();
  const [filteredItems, setFilteredItems] = React.useState<Item[]>([]);
  const fuse = React.useRef<Fuse<Item>>();

  React.useEffect(() => {
    const entities = getEntitiesWithValue(ItemPrototype, { value: true });
    console.log("creative items", entities);
    const unsortedItems = Array.from(entities).map((entity) => {
      return {
        name: entity as string, // TODO: update
        description: "tmp desc", // TODO: update
        blockId: entity,
      };
    });

    const options = {
      includeScore: true,
      keys: ["name", "description"],
    };

    fuse.current = new Fuse(unsortedItems, options);

    setItems(unsortedItems.sort((a, b) => a.name.localeCompare(b.name)));

    // TODO: this function is probably useful later
    // console.log(BlockIdToKey);
  }, [ItemPrototype]);

  React.useEffect(() => {
    if (!fuse.current) {
      return;
    }
    const result = fuse.current.search(searchValue);
    setFilteredItems(result.map((r) => r.item));
  }, [searchValue]);

  const resultArray = filteredItems.length > 0 ? filteredItems : items;

  const Slots = [...range(NUM_ROWS * NUM_COLS)].map((i) => {
    if (!resultArray || i >= resultArray.length) {
      return <Slot key={"voxel-search-slot" + i} disabled={true} />;
    }
    const item = resultArray[i];
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
    <div>
      <input
        value={searchValue}
        onChange={(e) => setSearchValue(e.target.value)}
      />
      <ActionBarWrapper>
        {[...range(NUM_COLS * NUM_ROWS)]
          .map((i) => i + NUM_COLS)
          .map((i) => Slots[i])}
      </ActionBarWrapper>
    </div>
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
