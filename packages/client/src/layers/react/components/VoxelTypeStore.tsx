import { Slot } from "./common";
import { Entity, getComponentValue, getEntitiesWithValue } from "@latticexyz/recs";
import { Layers } from "../../../types";
import { range } from "@latticexyz/utils";
import styled from "styled-components";
import React from "react";
import { getItemTypesIOwn } from "../../noa/systems/createInventoryIndexSystem";
import { INVENTORY_HEIGHT, INVENTORY_WIDTH } from "./InventoryHud";
import { toast } from "react-toastify";
import { VoxelBaseTypeIdToEntity } from "../../noa/types";
import { useVoxelTypeSearch } from "../../../utils/useVoxelTypeSearch";
import { SearchBar } from "./common/SearchBar";

export interface VoxelTypeStoreFilters {
  query: string;
}
interface Props {
  layers: Layers;
  filters: VoxelTypeStoreFilters;
  setFilters: React.Dispatch<React.SetStateAction<VoxelTypeStoreFilters>>;
}
const NUM_COLS = 5;
const NUM_ROWS = 7;

export interface VoxelTypeDesc {
  name: string;
  VoxelBaseTypeId: Entity;
  previewVoxelVariantId: string;
  numSpawns: BigInt;
  creator: string;
  scale: number;
  childVoxelTypeIds: string[];
}

export const VoxelTypeStore: React.FC<Props> = ({ layers, filters, setFilters }) => {
  const {
    network: {
      contractComponents: { OwnedBy, VoxelType },
      api: { giftVoxel },
      network: { connectedAddress },
      getVoxelIconUrl,
    },
    noa: { noa },
  } = layers;

  const { voxelTypesToDisplay } = useVoxelTypeSearch({ layers, filters });

  const Slots = [...range(NUM_ROWS * NUM_COLS)].map((i) => {
    if (!voxelTypesToDisplay || i >= voxelTypesToDisplay.length) {
      return <Slot key={"voxel-search-slot" + i} disabled={true} slotSize={"69px"} />;
    }
    const voxelDescription = voxelTypesToDisplay[i];

    const previewIconUrl = getVoxelIconUrl(voxelDescription.previewVoxelVariantId) || "";

    return (
      <Slot
        key={`creative-slot-${voxelDescription.name}`}
        slotSize={"69px"}
        voxelType={voxelDescription.VoxelBaseTypeId}
        iconUrl={previewIconUrl}
        quantity={undefined} // undefined so no number appears
        onClick={() => tryGiftVoxel(voxelDescription, previewIconUrl)}
        disabled={false} // false, so if you pick up the voxeltype, it still shows up in the creative inventory
        selected={false} // you can never select an voxeltype in the creative inventory
        tooltipText={
          <>
            <p>{voxelDescription.name}</p>
            {/* <p className="mt-1">By {voxelDescription.creator.substring(0, 5)}...</p> */}
            <p className="mt-1">{voxelDescription.numSpawns.toString()} Spawns</p>
          </>
        }
      />
    );
  });

  const tryGiftVoxel = (voxelTypeDesc: VoxelTypeDesc, previewIconUrl: string) => {
    // It's better to do this validation off-chain since doing it on-chain is expensive.
    // Also this is more of a UI limitation. Who knows, maybe in the future, we WILL enforce strict inventory limits
    const itemTypesIOwn = getItemTypesIOwn(noa, OwnedBy, VoxelType, connectedAddress);
    if (itemTypesIOwn.has(voxelTypeDesc.VoxelBaseTypeId) || itemTypesIOwn.size < INVENTORY_WIDTH * INVENTORY_HEIGHT) {
      giftVoxel(voxelTypeDesc.VoxelBaseTypeId, previewIconUrl);
    } else {
      toast(`Your inventory is full! Right click on an item to delete it.`);
    }
  };

  return (
    <div className="flex flex-col p-4">
      <div className="flex w-full">
        <SearchBar value={filters.query} onChange={(e) => setFilters({ ...filters, query: e.target.value })} />
      </div>
      <div className="flex w-full mt-5 justify-center items-center">
        <ActionBarWrapper>{[...range(NUM_COLS * NUM_ROWS)].map((i) => Slots[i])}</ActionBarWrapper>
      </div>
    </div>
  );
};

const ActionBarWrapper = styled.div`
  background-color: rgb(0 0 0 / 40%);
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  align-items: center;
  pointer-events: all;
  border: 5px lightgray solid;
  z-index: 10;
  position: relative;
`;
