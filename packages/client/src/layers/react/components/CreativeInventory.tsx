import { Slot } from "./common";
import { Entity, getComponentValue, getEntitiesWithValue } from "@latticexyz/recs";
import { Layers } from "../../../types";
import { range } from "@latticexyz/utils";
import styled from "styled-components";
import React from "react";
import Fuse from "fuse.js";
import { getItemTypesIOwn } from "../../noa/systems/createInventoryIndexSystem";
import { INVENTORY_HEIGHT, INVENTORY_WIDTH } from "./InventoryHud";
import { toast } from "react-toastify";
import { formatNamespace } from "../../../constants";
import { getNftStorageLink } from "../../noa/constants";
import { voxelVariantDataKeyToString } from "../../noa/types";

interface Props {
  layers: Layers;
}
const NUM_COLS = 9;
const NUM_ROWS = 6;

interface VoxelDescription {
  name: string;
  namespace: string;
  description: string;
  voxelType: Entity;
  voxelTypeId: string;
  preview: string;
}

export const CreativeInventory: React.FC<Props> = ({ layers }) => {
  const {
    components: { VoxelTypeRegistry },
    contractComponents: { OwnedBy, VoxelType },
    api: { giftVoxel },
    network: { connectedAddress },
    getVoxelIconUrl,
  } = layers.network;

  const [searchValue, setSearchValue] = React.useState<string>("");
  const [voxelDescriptions, setVoxelDescriptions] =
    React.useState<VoxelDescription[]>();
  const [filteredVoxelDescriptions, setFilteredVoxelDescriptions] =
    React.useState<VoxelDescription[]>([]);
  const fuse = React.useRef<Fuse<VoxelDescription>>();

  React.useEffect(() => {
    const allVoxelTypes = [...VoxelTypeRegistry.entities()];
    const voxelTypes = [];
    for (const voxelType of allVoxelTypes) {
      const voxelTypeValue = getComponentValue(VoxelTypeRegistry, voxelType);
      voxelTypes.push(voxelTypeValue);
    }
    console.log("creative voxelTypes", voxelTypes);
    const unsortedVoxelDescriptions = Array.from(voxelTypes).map(
      (voxelType, index: number) => {
        const entity = allVoxelTypes[index];
        const [namespace, voxelTypeId] = entity.split(":");
        return {
          name: voxelTypeId as string, // TODO: update
          namespace: formatNamespace(namespace),
          description: "tmp desc", // TODO: update
          voxelType: voxelTypeId as Entity,
          voxelTypeId: voxelTypeId,
          preview: voxelType && voxelType.preview ? getNftStorageLink(voxelType.preview) : "",
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
  }, [VoxelTypeRegistry]);

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
      return <Slot key={"voxel-search-slot" + i} disabled={true} getVoxelIconUrl={getVoxelIconUrl} />;
    }
    const voxelDescription = filteredVoxelDescriptions[i];

    return (
      <Slot
        key={"creative-slot" + i}
        voxelType={voxelDescription.voxelType}
        bgUrl={voxelDescription.preview}
        quantity={undefined} // undefined so no number appears
        onClick={() => tryGiftVoxel(voxelDescription.namespace, voxelDescription.voxelTypeId, voxelDescription.preview)}
        disabled={false} // false, so if you pick up the voxeltype, it still shows up in the creative inventory
        selected={false} // you can never select an voxeltype in the creative inventory
        getVoxelIconUrl={getVoxelIconUrl}
      />
    );
  });

  const tryGiftVoxel = (voxelTypeNamespace: string, voxelTypeId: string, preview: string) => {
    // It's better to do this validation off-chain since doing it on-chain is expensive.
    // Also this is more of a UI limitation. Who knows, maybe in the future, we WILL enforce strict inventory limits
    const itemTypesIOwn = getItemTypesIOwn(
      OwnedBy,
      VoxelType,
      connectedAddress
    );
    if (
      itemTypesIOwn.has(voxelVariantDataKeyToString({
        voxelVariantNamespace: voxelTypeNamespace,
        voxelVariantId: voxelTypeId,
      }) as Entity) ||
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
        value={searchValue}
        onChange={(e) => setSearchValue(e.target.value)}
      />
      <ActionBarWrapper>
        {[...range(NUM_COLS * NUM_ROWS)]
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
