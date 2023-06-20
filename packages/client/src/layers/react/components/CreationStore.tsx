import React, { ChangeEvent, KeyboardEvent, useEffect } from "react";
import { Layers } from "../../../types";
import { defineQuery, Has, Type } from "@latticexyz/recs";
import { useComponentValue, useObservableValue } from "@latticexyz/react";
import { ComponentUpdate } from "@latticexyz/recs/src/types";
import { UpdateType } from "@latticexyz/recs/src/constants";

export interface CreationStoreFilters {
  search: string;
  isMyCreation: boolean;
}

interface Props {
  layers: Layers;
  filters: CreationStoreFilters;
  setFilters: React.Dispatch<React.SetStateAction<CreationStoreFilters>>;
}

const CreationStore: React.FC<Props> = ({ layers, filters, setFilters }) => {
  const {
    noa: {
      components: { PersistentNotification },
      SingletonEntity,
      api: { toggleInventory },
    },
    network: {
      components: { VoxelTypes, RelativePositions, VoxelMetadata },
      api: { getEntityAtPosition, registerCreation },
    },
  } = layers;

  const [searchValue, setSearchValue] = React.useState<string>("");

  const creationsUpdate = useComponentValue(VoxelTypes, undefined);

  useEffect(() => {
    return;
  }, [searchValue]);

  useEffect(() => {
    const creationIds = VoxelTypes.entities();
    for (const creationId of creationIds) {
      console.log(creationId);
    }
  }, [creationsUpdate]);

  return (
    <div className="max-w-md mx-auto p-4 text-white">
      <input
        className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
        value={searchValue}
        onChange={(e) => setSearchValue(e.target.value)}
      />
      <p>{creationsUpdate?.value[0]?.toString()}</p>
    </div>
  );
};

export default CreationStore;
