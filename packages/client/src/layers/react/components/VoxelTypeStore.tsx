import { Slot } from "./common";
import { Entity, getComponentValue, getEntitiesWithValue } from "@latticexyz/recs";
import { Layers } from "../../../types";
import { range } from "@latticexyz/utils";
import styled from "styled-components";
import React from "react";
import { getItemTypesIOwn } from "../../noa/systems/createInventoryIndexSystem";
import { INVENTORY_HEIGHT, INVENTORY_WIDTH } from "./InventoryHud";
import { toast } from "react-toastify";
import { useVoxelTypeSearch } from "../../../utils/useVoxelTypeSearch";
import { SearchBar } from "./common/SearchBar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faFilter } from "@fortawesome/free-solid-svg-icons";
import { Button } from "@/components/ui/button";

export interface VoxelTypeStoreFilters {
  query: string;
  scale: number | null;
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
  voxelBaseTypeId: Entity;
  previewVoxelVariantId: string;
  numSpawns: BigInt;
  creator: string;
  scale: number;
  childVoxelTypeIds: string[];
}

export const VoxelTypeStore: React.FC<Props> = ({ layers, filters = { query: "", scale: null }, setFilters }) => {
  const {
    network: {
      walletClient,
      contractComponents: { OwnedBy, VoxelType },
      api: { giftVoxel },
      getVoxelIconUrl,
    },
    noa: { noa },
  } = layers;

  // const { voxelTypesToDisplay } = useVoxelTypeSearch({ layers, filters, scale: filters.scale !== null ? filters.scale : undefined });
  const { voxelTypesToDisplay } = useVoxelTypeSearch({ layers, filters, scale: filters.scale });

  const StyledDropdownMenuRadioItem = styled(DropdownMenuRadioItem)`
    cursor: pointer;
    border-radius: 2px;
    transition: background-color 0.3s ease, color 0.3s ease;

    &:hover {
      background-color: slategray;
      color: white;
    }
  `;

  const ScaleBar: React.FC<{ value: number | null; onChange: (val: string) => void }> = ({ value, onChange }) => {
    return (
      <DropdownMenu>
        <DropdownMenuTrigger>
          <Button variant="ghost" size="icon" className="rounded ml-2 mr-1 hover:bg-slate-500 ...">
            <FontAwesomeIcon className="h-4 w-4" icon={faFilter} style={{ color: "#C9CACB" }} />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent
          style={{
            zIndex: 1000,
            backgroundColor: "#374147",
            borderRadius: "5px",
            width: "fit-content",
            color: "white",
            border: "1px solid transparent",
          }}
          className="w-56"
        >
          <DropdownMenuLabel className="font-bold">Select Level</DropdownMenuLabel>
          <DropdownMenuSeparator className="bg-slate-300" />
          <DropdownMenuRadioGroup
            value={value === null || value === undefined ? "All" : value.toString()}
            onValueChange={onChange}
          >
            <StyledDropdownMenuRadioItem value="All">All Levels</StyledDropdownMenuRadioItem>
            {Array.from({ length: 10 }, (_, i) => i + 1).map((scale) => (
              <StyledDropdownMenuRadioItem key={scale} value={scale.toString()}>
                Level {scale}
              </StyledDropdownMenuRadioItem>
            ))}
          </DropdownMenuRadioGroup>
        </DropdownMenuContent>
      </DropdownMenu>
    );
  };

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
        voxelType={voxelDescription.voxelBaseTypeId}
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

  const connectedAddress = walletClient.account.address;
  const tryGiftVoxel = (voxelTypeDesc: VoxelTypeDesc, previewIconUrl: string) => {
    const itemTypesIOwn = getItemTypesIOwn(noa, OwnedBy, VoxelType, connectedAddress);
    if (itemTypesIOwn.has(voxelTypeDesc.voxelBaseTypeId) || itemTypesIOwn.size < INVENTORY_WIDTH * INVENTORY_HEIGHT) {
      giftVoxel(voxelTypeDesc.voxelBaseTypeId, previewIconUrl);
    } else {
      toast(`Your inventory is full! Right click on an item to delete it.`);
    }
  };

  return (
    <div className="flex flex-col p-4">
      <div className="flex w-full">
        <SearchBar value={filters.query} onChange={(e) => setFilters({ ...filters, query: e.target.value })} />
        <ScaleBar
          value={filters.scale}
          onChange={(val) => setFilters({ ...filters, scale: val === "All" ? null : parseInt(val) })}
        />
      </div>
      <div className="flex w-full mt-5 justify-center items-center">
        <ActionBarWrapper>{[...range(NUM_COLS * NUM_ROWS)].map((i) => Slots[i])}</ActionBarWrapper>
      </div>
    </div>
  );
};

export const ActionBarWrapper = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(69px, 1fr));
  align-items: center;
  pointer-events: all;
  width: 100%; // Ensure it takes up full width of the parent container

  z-index: 10;
  position: relative;
  transition: box-shadow 0.3s ease, transform 0.3s ease;
  & > div:hover {
    transform: scale(1.05);
  }
`;
