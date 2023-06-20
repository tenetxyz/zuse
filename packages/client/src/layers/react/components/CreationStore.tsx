import React, { ChangeEvent, KeyboardEvent, useEffect } from "react";
import { Layers } from "../../../types";
import {
  defineQuery,
  Entity,
  getComponentValue,
  Has,
  setComponent,
  Type,
} from "@latticexyz/recs";
import { useComponentValue, useObservableValue } from "@latticexyz/react";
import { ComponentUpdate } from "@latticexyz/recs/src/types";
import { UpdateType } from "@latticexyz/recs/src/constants";
import { VoxelCoord } from "@latticexyz/utils";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import Fuse from "fuse.js";

export interface CreationStoreFilters {
  search: string;
  isMyCreation: boolean;
}

interface Props {
  layers: Layers;
  filters: CreationStoreFilters;
  setFilters: React.Dispatch<React.SetStateAction<CreationStoreFilters>>;
}

interface Creation {
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
      components: { PersistentNotification },
      SingletonEntity,
      api: { toggleInventory },
    },
    network: {
      components: {
        OwnedBy,
        Description,
        Name,
        VoxelTypes,
        RelativePositions,
        VoxelMetadata,
      },
      api: { getEntityAtPosition, registerCreation },
    },
  } = layers;

  const [searchValue, setSearchValue] = React.useState<string>("");
  const [creations, setCreations] = React.useState<Creation[]>([]);
  const [creationsToDisplay, setCreationsToDisplay] = React.useState<
    Creation[]
  >([]);
  const fuse = React.useRef<Fuse<Creation>>();

  const creationsUpdate = useComponentValue(VoxelTypes, undefined);

  // There might be a better way to listen to the updates than using this useEffect, but I'm not sure
  useEffect(() => {
    const newCreations: Creation[] = [];
    const creationIds = VoxelTypes.entities();
    for (const creationId of creationIds) {
      console.log(creationId);

      const rawRelativePositions = getComponentValue(
        RelativePositions,
        creationId
      );
      const xPositions = rawRelativePositions?.x ?? [];
      const yPositions = rawRelativePositions?.y ?? [];
      const zPositions = rawRelativePositions?.z ?? [];

      const relativePositions = xPositions.map((x, i) => {
        return { x, y: yPositions[i], z: zPositions[i] };
      });

      newCreations.push({
        name: getComponentValue(Name, creationId)?.value ?? "",
        description: getComponentValue(Description, creationId)?.value ?? "",
        creationId,
        creator:
          getComponentValue(OwnedBy, creationId)?.value ?? SingletonEntity,
        voxelTypes: getComponentValue(VoxelTypes, creationId)?.value ?? [],
        relativePositions,
      } as Creation);
    }
    setCreations(newCreations);

    const options = {
      includeScore: true,
      keys: ["name", "description", "creator", "voxelTypes"],
    };

    fuse.current = new Fuse(newCreations, options);
  }, [creationsUpdate]);

  const spawnCreation = (creation: Creation) => {
    setComponent(PersistentNotification, SingletonEntity, {
      message: "press 'Enter' to place creation, 'e' to cancel",
      icon: NotificationIcon.NONE,
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
    <div className="max-w-md mx-auto p-4 text-white">
      <input
        className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
        value={searchValue}
        onChange={(e) => setSearchValue(e.target.value)}
      />
      <div className="m-2 p-2 flex flex-col">
        {creationsToDisplay.map((creation, idx) => {
          return (
            <div
              key={idx}
              className="border-1 border-solid border-slate-700 p-2 mb-2 flex flex-row whitespace-nowrap justify-around w-[300px] break-all justify-start"
            >
              <p>{creation.name}</p>
              <p>{creation.description}</p>
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
