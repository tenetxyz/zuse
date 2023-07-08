// This react hook returns a list of voxelTypes that meet the user's filter criteria
// when searching through the creative inventory
import React, { useEffect } from "react";
import Fuse from "fuse.js";
import { useComponentUpdate } from "./useComponentUpdate";
import { ComponentRecord, Layers } from "../types";
import { getComponentValue, Entity } from "@latticexyz/recs";
import { formatNamespace } from "../constants";
import { getNftStorageLink } from "../layers/noa/constants";
import { VoxelTypeStoreFilters, VoxelTypeDesc } from "../layers/react/components/VoxelTypeStore";

export interface Props {
  layers: Layers;
  filters: VoxelTypeStoreFilters;
}

export interface CreativeInventorySearch {
  voxelTypesToDisplay: VoxelTypeDesc[];
}

export const useVoxelTypeSearch = ({ layers, filters }: Props) => {
  const {
    network: {
      contractComponents: { VoxelTypeRegistry },
    },
  } = layers;

  const allVoxelTypes = React.useRef<VoxelTypeDesc[]>([]);
  const filteredVoxelTypes = React.useRef<VoxelTypeDesc[]>([]); // Filtered based on the specified filters. The user's search box query does NOT affect this.
  const [voxelTypesToDisplay, setVoxelTypesToDisplay] = React.useState<VoxelTypeDesc[]>([]);
  const fuse = React.useRef<Fuse<VoxelTypeDesc>>();

  useComponentUpdate(VoxelTypeRegistry, () => {
    const allVoxelTypesInRegistry = [...VoxelTypeRegistry.entities()];
    const voxelTypes = new Map<Entity, ComponentRecord<typeof VoxelTypeRegistry>>();
    for (const voxelType of allVoxelTypesInRegistry) {
      const voxelTypeRecord = getComponentValue(VoxelTypeRegistry, voxelType);
      if (!voxelTypeRecord) {
        console.warn(`cannot find voxelTypeRecord for ${voxelType}`);
        continue;
      }
      voxelTypes.set(voxelType, voxelTypeRecord);
    }
    allVoxelTypes.current = Array.from(voxelTypes.entries())
      .filter(([_, voxelTypeRecord]) => voxelTypeRecord !== undefined && voxelTypeRecord.name !== "Air")
      .map(([voxelType, voxelTypeRecord]) => {
        const [namespace, voxelTypeId] = voxelType.split(":");
        return {
          name: voxelTypeRecord!.name,
          namespace: formatNamespace(namespace),
          voxelType: voxelTypeId as Entity,
          previewVoxelVariantNamespace: voxelTypeRecord!.previewVoxelVariantNamespace,
          previewVoxelVariantId: voxelTypeRecord!.previewVoxelVariantId,
          numSpawns: voxelTypeRecord!.numSpawns,
          creator: voxelTypeRecord!.creator,
        } as VoxelTypeDesc;
      });

    allVoxelTypes.current = allVoxelTypes.current.sort((a, b) => a.name.localeCompare(b.name));

    // After we have parsed all the voxeltypes, apply the voxeltype
    // filters to narrow down the voxeltypes that will be displayed.
    applyFilters();
  });

  const applyFilters = () => {
    // TODO: add filters for the serach
    filteredVoxelTypes.current = allVoxelTypes.current;
    // TODO: add a sort function to sort by namespace
    const options = {
      includeScore: false,
      keys: ["name"],
    };

    fuse.current = new Fuse(filteredVoxelTypes.current, options);
    queryForVoxelTypesToDisplay();
  };
  // recalculate which voxelTypes are in the display pool when the filters change
  useEffect(applyFilters, [filters]);

  const queryForVoxelTypesToDisplay = () => {
    if (!fuse.current) {
      return;
    }
    if (filters.query === "") {
      setVoxelTypesToDisplay(filteredVoxelTypes.current);
      return;
    }

    const queryResult = fuse.current.search(filters.query).map((r) => r.item);
    setVoxelTypesToDisplay(queryResult);
  };
  React.useEffect(queryForVoxelTypesToDisplay, [filters.query]);

  return {
    voxelTypesToDisplay,
  };
};
