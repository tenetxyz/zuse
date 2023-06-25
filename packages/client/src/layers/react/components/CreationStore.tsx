import React, { ChangeEvent, KeyboardEvent, useEffect } from "react";
import { Layers } from "../../../types";
import { Entity, getEntityString, setComponent } from "@latticexyz/recs";
import { to256BitString, VoxelCoord } from "@latticexyz/utils";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import Fuse from "fuse.js";
import { onComponentChange } from "../../../utils/onComponentChange";

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
      contractComponents: { Creation },
      network: { connectedAddress },
    },
  } = layers;
  const playerAddress = to256BitString(connectedAddress.get() ?? "");

  const [searchValue, setSearchValue] = React.useState<string>("");
  const allCreations = React.useRef<Creation[]>([]);
  const filteredCreations = React.useRef<Creation[]>([]); // Filtered based on the specified filters. The user's search box query does NOT affect this.
  const [creationsToDisplay, setCreationsToDisplay] = React.useState<
    Creation[]
  >([]);
  const fuse = React.useRef<Fuse<Creation>>();

  onComponentChange(Creation, () => {
    allCreations.current = [];
    const creationTable = Creation.values;
    creationTable.name.forEach((name: string, creationId) => {
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

      allCreations.current.push({
        creationId: getEntityString(creationId),
        name: name,
        description: description,
        creator: creator,
        voxelTypes: voxelTypes,
        relativePositions,
      } as Creation);
    });

    // After we have parsed all the creations, apply the creation
    // filters to narrow down the creations that will be displayed.
    applyCreationFilters();
    debugger;
  });

  const applyCreationFilters = () => {
    filteredCreations.current = filters.isMyCreation
      ? allCreations.current.filter(
          (creation) => creation.creator === playerAddress
        )
      : allCreations.current;

    // only the filtered creations can be queried
    const options = {
      includeScore: false,
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
    if (searchValue === "") {
      setCreationsToDisplay(filteredCreations.current);
      return;
    }

    const queryResult = fuse.current.search(searchValue).map((r) => r.item);
    setCreationsToDisplay(queryResult);
  };
  React.useEffect(queryForCreationsToDisplay, [searchValue]);

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

  return (
    <div className="max-w-md mx-auto p-4 text-white flex flex-col content-start float-top h-full min-w-[800px]">
      <div className="flex flex-row">
        <input
          placeholder="Search"
          className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
          value={searchValue}
          onChange={(e) => setSearchValue(e.target.value)}
          autoComplete={"on"}
          name="creation search"
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
            name="is my creation filter"
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
