import React, { ChangeEvent, KeyboardEvent, useEffect } from "react";
import { Layers } from "../../../types";
import {
  defineQuery,
  Entity,
  getComponentValue,
  getEntityString,
  Has,
  setComponent,
  Type,
} from "@latticexyz/recs";
import { useComponentValue, useObservableValue } from "@latticexyz/react";
import { ComponentUpdate } from "@latticexyz/recs/src/types";
import { UpdateType } from "@latticexyz/recs/src/constants";
import { to256BitString, VoxelCoord } from "@latticexyz/utils";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import Fuse from "fuse.js";
import { formatEntityID } from "../../../utils/entity";

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
  creator: Entity;
  voxelTypes: string[];
  relativePositions: VoxelCoord[];
  // voxelMetadata: string[];
}

const CreationStore: React.FC<Props> = ({ layers, filters, setFilters }) => {
  const {
    noa: {
      components: { PersistentNotification, SpawnCreation },
      SingletonEntity,
      api: { toggleInventory },
    },
    network: {
      components: { OwnedBy, Creation },
      network: { connectedAddress },
      api: { getEntityAtPosition, registerCreation },
    },
  } = layers;
  const playerAddress = to256BitString(connectedAddress.get() ?? "");

  const [searchValue, setSearchValue] = React.useState<string>("");
  const [creations, setCreations] = React.useState<Creation[]>([]);
  const [creationsToDisplay, setCreationsToDisplay] = React.useState<
    Creation[]
  >([]);
  const fuse = React.useRef<Fuse<Creation>>();

  const creationsUpdate = useComponentValue(Creation, undefined);

  // There might be a better way to listen to the updates than using this useEffect, but I'm not sure
  useEffect(() => {
    const allCreations: Creation[] = [];
    const creationTable = Creation.values;
    creationTable.name.forEach((name, creationId) => {
      const description = ""; //creationTable.description.get(creationId) ?? "";
      const creator = creationTable.creator.get(creationId);
      if (!creator) {
        console.warn("No creator found for creation", creationId);
        return;
      }

      const voxelTypes = creationTable.voxelTypes.get(creationId) ?? [];
      if (voxelTypes.length === 0) {
        console.warn("No voxelTypes found for creation", creationId);
        return;
      }

      const xPositions = creationTable.relativePositionsX.get(creationId) ?? [];
      const yPositions = creationTable.relativePositionsY.get(creationId) ?? [];
      const zPositions = creationTable.relativePositionsZ.get(creationId) ?? [];

      if (
        xPositions.length === 0 ||
        yPositions.length === 0 ||
        zPositions.length === 0
      ) {
        console.warn(
          `No relativePositions found for creationId=${creationId.toString()}. xPositions=${xPositions} yPositions=${yPositions} zPositions=${zPositions}`
        );
        return;
      }

      const relativePositions = xPositions.map((x, i) => {
        return { x, y: yPositions[i], z: zPositions[i] };
      });
      // TODO: add voxelMetadata

      allCreations.push({
        creationId: getEntityString(creationId),
        name: name,
        description: description,
        creator: creator,
        voxelTypes: voxelTypes,
        relativePositions,
      } as Creation);
    });

    const newCreations = filters.isMyCreation
      ? allCreations.filter((creation) => creation.creator === playerAddress)
      : allCreations;

    setCreations(newCreations);

    const options = {
      includeScore: true, // PERF: make this false
      keys: ["name", "description", "creator", "voxelTypes"],
    };

    fuse.current = new Fuse(newCreations, options);
  }, [creationsUpdate, filters]);

  const spawnCreation = (creation: Creation) => {
    setComponent(PersistentNotification, SingletonEntity, {
      message: "press 'Enter' to place creation, 'e' to cancel",
      icon: NotificationIcon.NONE,
    });
    setComponent(SpawnCreation, SingletonEntity, {
      creation: creation,
    });
    toggleInventory();
  };

  React.useEffect(() => {
    if (!fuse.current || !creations) {
      return;
    }
    const result = fuse.current.search(searchValue).map((r) => r.item);
    const creationsToDisplay = result.length > 0 ? result : creations;
    setCreationsToDisplay(creationsToDisplay);
  }, [searchValue, creations]);

  return (
    <div className="max-w-md mx-auto p-4 text-white flex flex-col content-start float-top h-full min-w-[800px]">
      <div className="flex flex-row">
        <input
          placeholder="Search"
          className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
          value={searchValue}
          onChange={(e) => setSearchValue(e.target.value)}
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
              <p className="">{creation.relativePositions.length} voxels</p>
              <p className="break-all break-words">
                {creation.creator.substr(50)}
              </p>
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
