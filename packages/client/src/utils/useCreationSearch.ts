import React, { useEffect } from "react";
import { Creation, CreationStoreFilters } from "../layers/react/components/CreationStore";
import Fuse from "fuse.js";
import { useComponentUpdate } from "./useComponentUpdate";
import { Layers } from "../types";
import { getEntityString } from "@latticexyz/recs";
import { to256BitString } from "@latticexyz/utils";
import { VoxelCoord } from "@latticexyz/utils";
import { VoxelTypeKey, VoxelTypeKeyInMudTable } from "../layers/noa/types";
import { abiDecode, cleanObj } from "@/utils/encodeOrDecode";
import { decodeBaseCreations } from "./encodeOrDecode";

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
  name: string;
  description: string;
  spawns: CreationSpawns[];
};

export const parseCreationMetadata = (rawMetadata: string, worldAddress: string) => {
  const metaData: CreationMetadata = abiDecode(
    "tuple(string name,string description,tuple(address worldAddress, uint256 numSpawns)[] spawns)",
    rawMetadata
  );
  const name = metaData.name;
  const description = metaData.description;
  let numSpawns = 0;
  metaData.spawns.forEach((spawn) => {
    const cleanedSpawn = cleanObj(spawn);
    if (cleanedSpawn.worldAddress.toLowerCase() === worldAddress.toLowerCase()) {
      numSpawns = Number(cleanedSpawn.numSpawns);
    }
  });
  return { name, description, numSpawns };
};

export const useCreationSearch = ({ layers, filters }: Props) => {
  const {
    network: {
      registryComponents: { CreationRegistry },
      network: { connectedAddress },
      worldAddress,
    },
  } = layers;

  const allCreations = React.useRef<Creation[]>([]);
  const filteredCreations = React.useRef<Creation[]>([]); // Filtered based on the specified filters. The user's search box query does NOT affect this.
  const [creationsToDisplay, setCreationsToDisplay] = React.useState<Creation[]>([]);
  const fuse = React.useRef<Fuse<Creation>>();

  useComponentUpdate(CreationRegistry, () => {
    allCreations.current = [];
    const creationTable = CreationRegistry.values;
    creationTable.metadata.forEach((rawMetadata: string, creationId) => {
      const { name, description, numSpawns } = parseCreationMetadata(rawMetadata, worldAddress);
      const creator = creationTable.creator.get(creationId);
      if (!creator) {
        console.warn("No creator found for creation", creationId);
        return;
      }

      const rawVoxelTypes = creationTable.voxelTypes.get(creationId) ?? "";
      if (rawVoxelTypes.length === 0) {
        console.warn("No voxelTypes found for creation", creationId);
        return;
      }

      const voxelTypes: VoxelTypeKey[] = (
        abiDecode("tuple(bytes32 voxelTypeId,bytes32 voxelVariantId)[]", rawVoxelTypes) as VoxelTypeKeyInMudTable[]
      ).map((voxelKey) => {
        return {
          voxelBaseTypeId: voxelKey.voxelTypeId,
          voxelVariantTypeId: voxelKey.voxelVariantId,
        };
      });

      const encodedRelativePositions = creationTable.relativePositions.get(creationId) ?? "";
      const relativePositions =
        (abiDecode("tuple(int32 x,int32 y,int32 z)[]", encodedRelativePositions) as VoxelCoord[]) || [];

      const rawBaseCreations = creationTable.baseCreations.get(creationId);
      const baseCreations = rawBaseCreations ? decodeBaseCreations(rawBaseCreations) : [];

      if (relativePositions.length === 0 && baseCreations.length === 0) {
        console.warn(
          `No relativePositions and no base creations found for creationId=${creationId.toString()} (name=${name} creator=${creator}). This means that this creation has no voxels`
        );
        return;
      }

      // TODO: add voxelMetadata

      allCreations.current.push({
        creationId: getEntityString(creationId),
        name: name,
        description: description,
        creator: creator,
        voxelTypes: voxelTypes,
        relativePositions,
        numSpawns: numSpawns,
        numVoxels: creationTable.numVoxels.get(creationId) ?? 0,
        baseCreations,
      } as Creation);
    });

    allCreations.current = allCreations.current.sort((a, b) => {
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
