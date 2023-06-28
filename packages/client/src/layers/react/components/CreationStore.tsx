import React from "react";
import { Layers } from "../../../types";
import { Entity, setComponent } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import { useCreationSearch } from "../../../utils/useCreationSearch";

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
      components: { PersistentNotification, SpawnCreation },
      SingletonEntity,
      api: { toggleInventory },
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
    toggleInventory();
  };

  return (
    <div className="max-w-md mx-auto p-4 text-white flex flex-col content-start float-top h-full min-w-[800px]">
      <div className="flex flex-row">
        <input
          placeholder="Search"
          className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
          value={filters.search}
          onChange={(e) => {
            setFilters({ ...filters, search: e.target.value });
          }}
          autoComplete={"on"}
          name="search"
        />
        <label className="flex items-center space-x-2 ml-2">
          <span>My Creations</span>
          <input
            type="checkbox"
            className="form-checkbox text-indigo-600 h-5 w-5"
            checked={filters.isMyCreation}
            onChange={() => {
              setFilters({ ...filters, isMyCreation: !filters.isMyCreation });
            }}
            name="isMyCreationFilter"
          />
        </label>
      </div>
      <div className="m-2 p-2 flex flex-col">
        {creationsToDisplay.map((creation, idx) => {
          return (
            <div
              key={idx}
              className="border-1 border-solid border-slate-700 p-2 mb-2 flex flex-row whitespace-nowrap justify-around break-all justify-start space-x-5"
            >
              <p>{creation.name}</p>
              <p>{creation.description}</p>
              <p>{creation.relativePositions.length} voxels</p>
              <p>
                {creation.numSpawns.toString()} Spawn{creation.numSpawns.toString() !== "1" && "s"}
              </p>
              <p className="break-all break-words">{creation.creator.substr(50)}</p>
              <button
                className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid"
                onClick={() => {
                  spawnCreation(creation);
                }}
              >
                Spawn
              </button>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default CreationStore;
