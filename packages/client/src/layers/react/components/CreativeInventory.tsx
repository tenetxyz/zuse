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

interface VoxelType {
  name: string;
  description: string;
  blockId: Entity;
}

export const CreativeInventory: React.FC<Props> = ({ layers }) => {
  const {
    components: { VoxelTypePrototype },
    api: { giftVoxel },
  } = layers.network;

  const [searchValue, setSearchValue] = React.useState<string>("");
  const [voxeltypes, setVoxelTypes] = React.useState<VoxelType[]>();
  const [filteredVoxelTypes, setFilteredVoxelTypes] = React.useState<VoxelType[]>([]);
  const fuse = React.useRef<Fuse<VoxelType>>();

  React.useEffect(() => {
    const entities = getEntitiesWithValue(VoxelTypePrototype, { value: true });
    console.log("creative voxeltypes", entities);
    const unsortedVoxelTypes = Array.from(entities).map((entity) => {
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

    fuse.current = new Fuse(unsortedVoxelTypes, options);

    setVoxelTypes(unsortedVoxelTypes.sort((a, b) => a.name.localeCompare(b.name)));

    // TODO: this function is probably useful later
    // console.log(BlockIdToKey);
  }, [VoxelTypePrototype]);

  React.useEffect(() => {
    if (!fuse.current) {
      return;
    }
    const result = fuse.current.search(searchValue);
    setFilteredVoxelTypes(result.map((r) => r.voxeltype));
  }, [searchValue]);

  const resultArray = filteredVoxelTypes.length > 0 ? filteredVoxelTypes : voxeltypes;

  const Slots = [...range(NUM_ROWS * NUM_COLS)].map((i) => {
    if (!resultArray || i >= resultArray.length) {
      return <Slot key={"voxel-search-slot" + i} disabled={true} />;
    }
    const voxeltype = resultArray[i];
    return (
      <Slot
        key={"slot" + i}
        blockID={voxeltype.blockId}
        quantity={undefined} // undefined so no number appears
        onClick={() => giftVoxel(voxeltype.blockId)}
        disabled={false} // false, so if you pick up the voxeltype, it still shows up in the creative inventory
        selected={false} // you can never select an voxeltype in the creative inventory
      />
    );
  });

  // TODO: figure out if this rendering logic is correct
  return (
    <div>
      <input
        className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
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
  align-voxeltypes: center;
  pointer-events: all;
  border: 5px lightgray solid;
  z-index: 10;
  position: relative;
`;
