import { Slot } from "./common";
import { Entity, getComponentValue, getEntitiesWithValue } from "@latticexyz/recs";
import { Layers } from "../../../types";
import { range } from "@latticexyz/utils";
import styled from "styled-components";
import React from "react";
import { getItemTypesIOwn } from "../../noa/systems/createInventoryIndexSystem";
import { INVENTORY_HEIGHT, INVENTORY_WIDTH } from "./InventoryHud";
import { toast } from "react-toastify";
import { voxelTypeBaseKeyToEntity } from "../../noa/types";
import { useVoxelTypeSearch } from "../../../utils/useVoxelTypeSearch";

export interface VoxelTypeStoreFilters {
  query: string;
}
interface Props {
  layers: Layers;
  filters: VoxelTypeStoreFilters;
  setFilters: React.Dispatch<React.SetStateAction<VoxelTypeStoreFilters>>;
}
const NUM_COLS = 9;
const NUM_ROWS = 6;

export interface VoxelTypeDesc {
  name: string;
  namespace: string;
  voxelType: Entity;
  previewVoxelVariantId: string;
  previewVoxelVariantNamespace: string;
  numSpawns: BigInt;
  creator: string;
}

export const VoxelTypeStore: React.FC<Props> = ({ layers, filters, setFilters }) => {
  const {
    contractComponents: { OwnedBy, VoxelType },
    api: { giftVoxel },
    network: { connectedAddress },
    getVoxelIconUrl,
  } = layers.network;

  const { voxelTypesToDisplay } = useVoxelTypeSearch({ layers, filters });

  const Slots = [...range(NUM_ROWS * NUM_COLS)].map((i) => {
    if (!voxelTypesToDisplay || i >= voxelTypesToDisplay.length) {
      return <Slot key={"voxel-search-slot" + i} disabled={true} />;
    }
    const voxelDescription = voxelTypesToDisplay[i];

    const previewIconUrl =
      getVoxelIconUrl({
        voxelVariantNamespace: voxelDescription.previewVoxelVariantNamespace,
        voxelVariantId: voxelDescription.previewVoxelVariantId,
      }) || "";

    return (
      <Slot
        key={`creative-slot-${voxelDescription.name}`}
        voxelType={voxelDescription.voxelType}
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

  const tryGiftVoxel = (voxelType: VoxelTypeDesc, previewIconUrl: string) => {
    // It's better to do this validation off-chain since doing it on-chain is expensive.
    // Also this is more of a UI limitation. Who knows, maybe in the future, we WILL enforce strict inventory limits
    const itemTypesIOwn = getItemTypesIOwn(OwnedBy, VoxelType, connectedAddress);
    if (
      itemTypesIOwn.has(
        voxelTypeBaseKeyToEntity({
          voxelTypeNamespace: voxelType.namespace,
          voxelTypeId: voxelType.voxelType,
        })
      ) ||
      itemTypesIOwn.size < INVENTORY_WIDTH * INVENTORY_HEIGHT
    ) {
      giftVoxel(voxelType.namespace, voxelType.voxelType, previewIconUrl);
    } else {
      toast(`Your inventory is full! Right click on an item to delete it.`);
    }
  };

  return (
    <div>
      <input
        className="bg-white p-1 mb-5 focus:outline-slate-700 border-1 border-solid text-slate-800 rounded-md"
        value={filters.query}
        onChange={(e) => setFilters({ ...filters, query: e.target.value })}
        placeholder="Search"
      />
      <ActionBarWrapper>{[...range(NUM_COLS * NUM_ROWS)].map((i) => Slots[i])}</ActionBarWrapper>
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