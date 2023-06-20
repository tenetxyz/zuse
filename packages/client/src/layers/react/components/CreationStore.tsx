import React, { ChangeEvent, KeyboardEvent, useEffect } from "react";
import { Layers } from "../../../types";
import {
  defineQuery,
  Entity,
  Has,
  HasValue,
  setComponent,
} from "@latticexyz/recs";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import { IVoxelSelection } from "../../noa/components/VoxelSelection";
import { calculateMinMax } from "../../../utils/voxels";
import { useComponentValue, useObservableValue } from "@latticexyz/react";
import { to64CharAddress } from "../../../utils/entity";
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

  const creationsUpdate: (ComponentUpdate & { type: UpdateType }) | undefined =
    useObservableValue(
      defineQuery(
        // I think if we inline this query, we aren't going to re-subscribe on re-renders
        [Has(VoxelTypes), Has(RelativePositions), Has(VoxelMetadata)],
        {
          runOnInit: true,
        }
      ).update$
    );

  useEffect(() => {
    console.log(searchValue);
  }, [searchValue]);

  return (
    <div className="max-w-md mx-auto p-4 text-slate-700">
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
