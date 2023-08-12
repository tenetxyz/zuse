import React, { useEffect } from "react";
import { CreationStoreFilters } from "../layers/react/components/CreationStore";
import Fuse from "fuse.js";
import { useComponentUpdate } from "./useComponentUpdate";
import { Layers } from "../types";
import { getEntityString } from "@latticexyz/recs";
import { to256BitString } from "@latticexyz/utils";
import { VoxelCoord } from "@latticexyz/utils";
import { VoxelTypeKey, VoxelTypeKeyInMudTable } from "../layers/noa/types";
import { abiDecode, cleanObj } from "@/utils/encodeOrDecode";
import { decodeBaseCreations } from "./encodeOrDecode";
import { Creation } from "@/mud/componentParsers/creation";
import { useParsedComponentUpdate } from "@/mud/componentParsers/componentParser";

export interface Props {
  layers: Layers;
  filters: CreationStoreFilters;
}

export interface CreationSearch {
  creationsToDisplay: Creation[];
}

export type CreationSpawns = {
  worldAddress: string;
  numSpawns: BigInt;
};

export type CreationMetadata = {
  creator: string;
  name: string;
  description: string;
  spawns: CreationSpawns[];
};

export const parseCreationMetadata = (rawMetadata: string, worldAddress: string) => {
  const metaData: CreationMetadata = abiDecode(
    "tuple(address creator, string name,string description,tuple(address worldAddress, uint256 numSpawns)[] spawns)",
    rawMetadata
  );
  const creator = metaData.creator;
  const name = metaData.name;
  const description = metaData.description;
  let numSpawns = 0;
  metaData.spawns.forEach((spawn) => {
    const cleanedSpawn = cleanObj(spawn);
    if (cleanedSpawn.worldAddress.toLowerCase() === worldAddress.toLowerCase()) {
      numSpawns = Number(cleanedSpawn.numSpawns);
    }
  });
  return { creator, name, description, numSpawns };
};

export const useCreationSearch = ({ layers, filters }: Props) => {
  const {
    network: {
      parsedComponents: { ParsedCreationRegistry },
      network: { connectedAddress },
      worldAddress,
    },
  } = layers;

  const allCreations = React.useRef<Creation[]>([]);
  const filteredCreations = React.useRef<Creation[]>([]); // Filtered based on the specified filters. The user's search box query does NOT affect this.
  const [creationsToDisplay, setCreationsToDisplay] = React.useState<Creation[]>([]);
  const fuse = React.useRef<Fuse<Creation>>();

  useParsedComponentUpdate<Creation>(
    ParsedCreationRegistry,
    (update, componentRows) => {
      allCreations.current = Array.from(componentRows.values()).sort((a, b) => {
        if (a.numSpawns > b.numSpawns) {
          return -1;
        } else if (a.numSpawns < b.numSpawns) {
          return 1;
        } else {
          return 0;
        }
      });

      // After we have parsed all the creations, apply the creation
      // filters to narrow down the creations that will be displayed.
      applyCreationFilters();
    },
    true
  );

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
    fuse.current = new Fuse(filteredCreations.current, options);

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
