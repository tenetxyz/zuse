import React from "react";
import { Layers } from "../../../types";
import { Entity, setComponent } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import { useCreationSearch } from "../../../utils/useCreationSearch";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { SearchBar } from "./common/SearchBar";

export interface CreationStoreFilters {
  search: string;
  isMyCreation: boolean;
}

interface Props {
  layers: Layers;
  filters: CreationStoreFilters;
  setFilters: React.Dispatch<React.SetStateAction<CreationStoreFilters>>;
}

export interface Creation {
  name: string;
  description: string;
  creationId: Entity;
  creator: string;
  voxelTypes: string[];
  relativePositions: VoxelCoord[];
  numSpawns: BigInt;
  // voxelMetadata: string[];
}

const CreationStore: React.FC<Props> = ({ layers, filters, setFilters }) => {
  const {
    noa: {
      components: { PersistentNotification, SpawnCreation, FocusedUi },
      SingletonEntity,
      noa,
    },
  } = layers;

  const { creationsToDisplay } = useCreationSearch({ layers, filters });

  const spawnCreation = (creation: Creation) => {
    setComponent(PersistentNotification, SingletonEntity, {
      message: "press 'Enter' to place creation, 'backspace' to cancel",
      icon: NotificationIcon.NONE,
    });
    setComponent(SpawnCreation, SingletonEntity, {
      creation: creation,
    });
    noa.blockTestDistance = 30; // increase the distance so placing creations is easier for players
    setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.WORLD });
  };

  return (
    <div className="flex flex-col p-4">
      <div className="flex w-full">
        <SearchBar
          value={filters.search}
          onChange={(e) => {
            setFilters({ ...filters, search: e.target.value });
          }}
        />
      </div>
      <div className="flex w-full mt-5 justify-center items-center"></div>
    </div>
  );
};

export default CreationStore;
