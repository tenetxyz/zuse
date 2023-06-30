import React, { useEffect } from "react";
import { Creation, CreationStoreFilters } from "../layers/react/components/CreationStore";
import Fuse from "fuse.js";
import { useComponentUpdate } from "./useComponentUpdate";
import { Layers } from "../types";
import { getEntityString } from "@latticexyz/recs";
import { to256BitString } from "@latticexyz/utils";
import { VoxelCoord } from "@latticexyz/utils";
import { cleanVoxelCoord } from "../layers/noa/types";
import { abiDecode } from "./abi";

export interface Props {
  layers: Layers;
  filters: CreationStoreFilters;
}

export interface CreationSearch {
  creationsToDisplay: Creation[];
}

export const useCreationSearch = ({ layers, filters }: Props) => {
  const {
    network: {
      contractComponents: { Creation },
      network: { connectedAddress },
    },
  } = layers;

  const allCreations = React.useRef<Creation[]>([]);
  const filteredCreations = React.useRef<Creation[]>([]); // Filtered based on the specified filters. The user's search box query does NOT affect this.
  const [creationsToDisplay, setCreationsToDisplay] = React.useState<Creation[]>([]);
  const fuse = React.useRef<Fuse<Creation>>();

  useComponentUpdate(Creation, () => {
    allCreations.current = [];
    const creationTable = Creation.values;
    creationTable.name.forEach((name: string, creationId) => {
      const description = creationTable.description.get(creationId) ?? "";
      const creator = creationTable.creator.get(creationId);
      if (!creator) {
        console.warn("No creator found for creation", creationId);
        return;
      }

      const voxelTypes = creationTable.voxelTypes.get(creationId) ?? [];
      // debugger;
      if (voxelTypes.length === 0) {
        console.warn("No voxelTypes found for creation", creationId);
        return;
      }

      const relativePositions: VoxelCoord[] = [];
      const encodedRelativePositions = creationTable.relativePositions.get(creationId) ?? "";
      const decodedRelativePositions = abiDecode("tuple(int32 x,int32 y,int32 z)[]", encodedRelativePositions);
      if (decodedRelativePositions) {
        decodedRelativePositions.forEach((relativePosition: VoxelCoord) => {
          relativePositions.push(cleanVoxelCoord(relativePosition));
        });
      }

      if (relativePositions.length === 0) {
        console.warn(
          `No relativePositions found for creationId=${creationId.toString()}. relativePositions=${relativePositions}`
        );
        return;
      }

      // TODO: add voxelMetadata

      allCreations.current.push({
        creationId: getEntityString(creationId),
        name: name,
        description: description,
        creator: creator,
        voxelTypes: voxelTypes as string[],
        relativePositions,
        numSpawns: creationTable.numSpawns.get(creationId) ?? 0,
      } as Creation);
    });
    allCreations.current = allCreations.current.sort((a, b) => a.name.localeCompare(b.name));

    // After we have parsed all the creations, apply the creation
    // filters to narrow down the creations that will be displayed.
    applyCreationFilters();
  });

  const applyCreationFilters = () => {
    const playerAddress = to256BitString(connectedAddress.get() ?? "");
    filteredCreations.current = filters.isMyCreation
      ? allCreations.current.filter((creation) => creation.creator === playerAddress)
      : allCreations.current;

    // only the filtered creations can be queried
    const options = {
      includeScore: false,
      // TODO: the creator is just an address. we need to replace it with a readable name
      keys: ["name", "description", "creator", "voxelTypes"],
    };
    fuse.current = new Fuse(allCreations.current, options);

    queryForCreationsToDisplay();
  };
  // recalculate which creations are in the display pool when the filters change
  useEffect(applyCreationFilters, [filters]);

  const queryForCreationsToDisplay = () => {
    if (!fuse.current) {
      return;
    }
    if (filters.search === "") {
      setCreationsToDisplay(filteredCreations.current);
      return;
    }

    const queryResult = fuse.current.search(filters.search).map((r) => r.item);
    setCreationsToDisplay(queryResult);
  };
  React.useEffect(queryForCreationsToDisplay, [filters.search]);

  return {
    creationsToDisplay,
  };
};
