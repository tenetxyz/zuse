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
const NUM_COLS = 5;
const NUM_ROWS = 7;

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
      return <Slot key={"voxel-search-slot" + i} disabled={true} slotSize={"69px"} />;
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
        slotSize={"69px"}
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
    <div className="flex flex-col p-4">
      <div className="flex w-full">
        <label className="mb-2 text-sm font-medium text-gray-900 sr-only">Search</label>
        <div className="relative w-full">
          <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
            <svg
              className="w-4 h-4 text-gray-500"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 20 20"
            >
              <path
                stroke="currentColor"
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"
              />
            </svg>
          </div>
          <input
            type="search"
            id="search"
            className="block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Search"
            value={filters.query}
            onChange={(e) => setFilters({ ...filters, query: e.target.value })}
            required
          />
        </div>
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
