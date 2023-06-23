import { Slot } from "./common";
import { Entity, getEntitiesWithValue } from "@latticexyz/recs";
import { Layers } from "../../../types";
import { range } from "@latticexyz/utils";
import styled from "styled-components";
import React from "react";
import Fuse from "fuse.js";
import { getItemTypesIOwn } from "../../noa/systems/createInventoryIndexSystem";
import { INVENTORY_HEIGHT, INVENTORY_WIDTH } from "./InventoryHud";
import { toast } from "react-toastify";

interface Props {
  layers: Layers;
}
const NUM_COLS = 9;
const NUM_ROWS = 8;

interface VoxelDescription {
  name: string;
  description: string;
  voxelType: Entity;
}

export const CreativeInventory: React.FC<Props> = ({ layers }) => {
  const {
    components: { VoxelPrototype },
    contractComponents: { OwnedBy, VoxelType },
    api: { giftVoxel },
    network: { connectedAddress },
  } = layers.network;

  const [searchValue, setSearchValue] = React.useState<string>("");
  const [voxelDescriptions, setVoxelDescriptions] =
    React.useState<VoxelDescription[]>();
  const [filteredVoxelDescriptions, setFilteredVoxelDescriptions] =
    React.useState<VoxelDescription[]>([]);
  const fuse = React.useRef<Fuse<VoxelDescription>>();

  React.useEffect(() => {
    const voxelTypes = getEntitiesWithValue(VoxelPrototype, { value: true });
    console.log("creative voxelTypes", voxelTypes);
    const unsortedVoxelDescriptions = Array.from(voxelTypes).map(
      (voxelType) => {
        return {
          name: voxelType as string, // TODO: update
          description: "tmp desc", // TODO: update
          voxelType,
        };
      }
    );

    const options = {
      includeScore: true, // PERF: make this false
      keys: ["name", "description"],
    };

    fuse.current = new Fuse(unsortedVoxelDescriptions, options);

    setVoxelDescriptions(
      unsortedVoxelDescriptions.sort((a, b) => a.name.localeCompare(b.name))
    );
  }, [VoxelPrototype]);

  React.useEffect(() => {
    if (!fuse.current || !voxelDescriptions) {
      return;
    }
    const result = fuse.current.search(searchValue).map((r) => r.item);
    const descriptionsToDisplay =
      result.length > 0 ? result : voxelDescriptions;
    setFilteredVoxelDescriptions(descriptionsToDisplay);
  }, [searchValue, voxelDescriptions]);

  const Slots = [...range(NUM_ROWS * NUM_COLS)].map((i) => {
    if (!filteredVoxelDescriptions || i >= filteredVoxelDescriptions.length) {
      return <Slot key={"voxel-search-slot" + i} disabled={true} />;
    }
    const voxelDescription = filteredVoxelDescriptions[i];
    return (
      <Slot
        key={"slot" + i}
        voxelType={voxelDescription.voxelType}
        quantity={undefined} // undefined so no number appears
        onClick={() => tryGiftVoxel(voxelDescription.voxelType)}
        disabled={false} // false, so if you pick up the voxeltype, it still shows up in the creative inventory
        selected={false} // you can never select an voxeltype in the creative inventory
      />
    );
  });

  const tryGiftVoxel = (voxelType: Entity) => {
    // It's better to do this validation off-chain since doing it on-chain is expensive.
    // Also this is more of a UI limitation. Who knows, maybe in the future, we WILL enforce strict inventory limits
    const itemTypesIOwn = getItemTypesIOwn(
      OwnedBy,
      VoxelType,
      connectedAddress
    );
    if (
      itemTypesIOwn.has(voxelType) ||
      itemTypesIOwn.size < INVENTORY_WIDTH * INVENTORY_HEIGHT
    ) {
      giftVoxel(voxelType);
    } else {
      toast(`Your inventory is full! Right click on an item to delete it.`);
    }
  };

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
  align-items: center;
  pointer-events: all;
  border: 5px lightgray solid;
  z-index: 10;
  position: relative;
`;
