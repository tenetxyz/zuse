import { Slot } from "./common";
import { Entity, getComponentValue, getEntitiesWithValue } from "@latticexyz/recs";
import { Layers } from "../../../types";
import { range } from "@latticexyz/utils";
import styled from "styled-components";
import React from "react";
import { getItemTypesIOwn } from "../../noa/systems/createInventoryIndexSystem";
import { INVENTORY_HEIGHT, INVENTORY_WIDTH } from "./InventoryHud";
import { toast } from "react-toastify";
import { voxelVariantDataKeyToString } from "../../noa/types";
import { useCreativeInventorySearch } from "../../../utils/useCreativeInventorySearch";

export interface CreativeInventoryFilters {
  query: string;
}
interface Props {
  layers: Layers;
  filters: CreativeInventoryFilters;
  setFilters: React.Dispatch<React.SetStateAction<CreativeInventoryFilters>>;
}
const NUM_COLS = 9;
const NUM_ROWS = 6;

export interface VoxelTypeDesc {
  name: string;
  namespace: string;
  voxelType: Entity;
  preview: string;
  numSpawns: BigInt;
  creator: string;
}

export const CreativeInventory: React.FC<Props> = ({ layers, filters, setFilters }) => {
  const {
    components: { VoxelTypeRegistry },
    contractComponents: { OwnedBy, VoxelType },
    api: { giftVoxel },
    network: { connectedAddress },
    getVoxelIconUrl,
  } = layers.network;

  const { voxelTypesToDisplay } = useCreativeInventorySearch({ layers, filters });

  const Slots = [...range(NUM_ROWS * NUM_COLS)].map((i) => {
    if (!voxelTypesToDisplay || i >= voxelTypesToDisplay.length) {
      return <Slot key={"voxel-search-slot" + i} disabled={true} getVoxelIconUrl={getVoxelIconUrl} />;
    }
    const voxelDescription = voxelTypesToDisplay[i];

    return (
      <Slot
        key={`creative-slot-${voxelDescription.name}`}
        voxelType={voxelDescription.voxelType}
        iconUrl={voxelDescription.preview}
        quantity={undefined} // undefined so no number appears
        onClick={() => tryGiftVoxel(voxelDescription.namespace, voxelDescription.voxelType, voxelDescription.preview)}
        disabled={false} // false, so if you pick up the voxeltype, it still shows up in the creative inventory
        selected={false} // you can never select an voxeltype in the creative inventory
        getVoxelIconUrl={getVoxelIconUrl}
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

  const tryGiftVoxel = (voxelTypeNamespace: string, voxelTypeId: string, preview: string) => {
    // It's better to do this validation off-chain since doing it on-chain is expensive.
    // Also this is more of a UI limitation. Who knows, maybe in the future, we WILL enforce strict inventory limits
    const itemTypesIOwn = getItemTypesIOwn(OwnedBy, VoxelType, connectedAddress);
    if (
      itemTypesIOwn.has(
        voxelVariantDataKeyToString({
          voxelVariantNamespace: voxelTypeNamespace,
          voxelVariantId: voxelTypeId,
        }) as Entity
      ) ||
      itemTypesIOwn.size < INVENTORY_WIDTH * INVENTORY_HEIGHT
    ) {
      giftVoxel(voxelTypeNamespace, voxelTypeId, preview);
    } else {
      toast(`Your inventory is full! Right click on an item to delete it.`);
    }
  };

  return (
    <div>
      <input
        className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
        value={filters.query}
        onChange={(e) => setFilters({ ...filters, query: e.target.value })}
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
