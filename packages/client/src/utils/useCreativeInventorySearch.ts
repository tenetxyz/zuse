import React, { useEffect } from "react";
import Fuse from "fuse.js";
import { useComponentUpdate } from "./useComponentUpdate";
import { Layers } from "../types";
import { getComponentValue, Entity } from "@latticexyz/recs";
import { formatNamespace } from "../constants";
import { getNftStorageLink } from "../layers/noa/constants";
import { CreativeInventoryFilters, VoxelTypeDesc } from "../layers/react/components/CreativeInventory";

export interface Props {
  layers: Layers;
  filters: CreativeInventoryFilters;
}

export interface CreativeInventorySearch {
  voxelTypesToDisplay: VoxelTypeDesc[];
}

export const useCreativeInventorySearch = ({ layers, filters }: Props) => {
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
    const voxelTypes = [];
    for (const voxelType of allVoxelTypesInRegistry) {
      const voxelTypeValue = getComponentValue(VoxelTypeRegistry, voxelType);
      voxelTypes.push(voxelTypeValue);
    }
    allVoxelTypes.current = Array.from(voxelTypes)
      .filter((voxelType) => voxelType !== undefined && voxelType.name !== "Air") // we don't want unknown voxelTypes or Air to appear in the inventory
      .map((voxelType, index: number) => {
        const entity = allVoxelTypesInRegistry[index];
        const [namespace, voxelTypeId] = entity.split(":");
        return {
          name: voxelType!.name,
          namespace: formatNamespace(namespace),
          voxelType: voxelTypeId as Entity,
          voxelTypeId: voxelTypeId,
          preview: voxelType!.preview ? getNftStorageLink(voxelType!.preview) : "",
          numSpawns: voxelType!.numSpawns,
          creator: voxelType!.creator,
        };
      });

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
