import React from "react";
import { Layers } from "../../../types";
import { Entity, getComponentValue, setComponent } from "@latticexyz/recs";
import { useCreationSearch } from "../../../utils/useCreationSearch";
import { useClassifierSearch } from "./useClassifierSearch";
import { CreationStoreFilters } from "./CreationStore";
import { useComponentValue } from "@latticexyz/react";
import { SetState } from "../../../utils/types";
import { voxelTypeDataKeyToVoxelVariantDataKey } from "../../noa/types";
import { stringToVoxelCoord } from "../../../utils/coord";
import { ClassifierResults } from "./ClassifierResults";

export interface ClassifierStoreFilters {
  classifierQuery: string;
  creationFilter: CreationStoreFilters;
}

interface Props {
  layers: Layers;
  filters: ClassifierStoreFilters;
  setFilters: SetState<ClassifierStoreFilters>;
  selectedClassifier: Classifier | null;
  setSelectedClassifier: SetState<Classifier | null>;
}

export interface Classifier {
  name: string;
  description: string;
  classifierId: Entity;
  creator: Entity;
  functionSelector: string;
  classificationResultTableName: string;
  namespace: string;
}

const ClassifierStore: React.FC<Props> = ({
  layers,
  filters,
  setFilters,
  selectedClassifier,
  setSelectedClassifier,
}: Props) => {
  const {
    noa: {
      components: { SpawnToClassify, VoxelInterfaceSelection },
      SingletonEntity,
    },
    network: {
      components: { VoxelType, OfSpawn },
      api: { getEntityAtPosition, classifyCreation },
      getVoxelIconUrl,
    },
  } = layers;
  const { creationsToDisplay } = useCreationSearch({
    layers,
    filters: filters.creationFilter,
  });

  const { classifiersToDisplay } = useClassifierSearch({
    layers,
    filters,
  });

  const spawnToUse = useComponentValue(SpawnToClassify, SingletonEntity);

  const detailsForSpawnToClassify = (classifierId: Entity) => {
    if (!spawnToUse?.creation || !spawnToUse?.spawn) {
      return <p>Please look at a spawn of a creation and press the button to classify it</p>;
    }

    const spawnId: Entity = spawnToUse.spawn.spawnId;

    const interfaceVoxels = Array.from(
      getComponentValue(VoxelInterfaceSelection, SingletonEntity)?.value ?? new Set<string>()
    )
      .map((voxelCoordString) => stringToVoxelCoord(voxelCoordString))
      .map((voxelCoord) => getEntityAtPosition(voxelCoord))
      .filter((entityId) => {
        if (!entityId) {
          return false;
        }
        const interfaceSpawnId = getComponentValue(OfSpawn, entityId)?.value;
        // we only want the interface selections on the voxels that are part of this spawn
        return interfaceSpawnId === spawnId;
      });

    return (
      <div className="flex flex-col space-y-2">
        <div className="flex flex-row">
          <p>Submit {spawnToUse.creation.name} </p>
          <button
            onClick={() => {
              setComponent(SpawnToClassify, SingletonEntity, { spawn: undefined, creation: undefined });
            }}
          >
            (X)
          </button>
        </div>
        <p>Interfaces</p>
        {renderInterfaceVoxelImages(interfaceVoxels as Entity[])}
        <button
          onClick={() => {
            classifyCreation(classifierId, spawnId, interfaceVoxels);
          }}
        >
          Submit
        </button>
      </div>
    );
  };

  const renderInterfaceVoxelImages = (interfaceVoxels: Entity[]) => {
    return (
      <div className="flex flex-row space-x-2">
        {interfaceVoxels.map((voxel, idx) => {
          if (!voxel) {
            console.warn("Voxel not found at coord", voxel);
            return <div key={idx}>:(</div>;
          }
          const voxelType = getComponentValue(VoxelType, voxel);
          if (!voxelType) {
            console.warn("Voxel type not found for voxel", voxel);
            return <div key={idx}>:(</div>;
          }

          const iconKey = voxelTypeDataKeyToVoxelVariantDataKey(voxelType);
          const iconUrl = getVoxelIconUrl(iconKey);
          return (
            <div key={idx} className="bg-slate-100 p-1">
              <img src={iconUrl} />
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div className="flex flex-col p-4">
      <div className="flex w-full">
        <label className="mb-2 text-sm font-medium text-gray-900 sr-only">Search</label>
        <div className="relative w-full">
          <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
            <svg
              className="w-4 h-4 text-gray-500"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 20 20"
            >
              <path
                stroke="currentColor"
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"
              />
            </svg>
          </div>
          <input
            type="search"
            id="search"
            className="block w-full p-4 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Search"
            value={filters.classifierQuery}
            onChange={(e) => {
              setFilters({ ...filters, classifierQuery: e.target.value });
            }}
            required
          />
        </div>
      </div>
      <div className="flex w-full mt-5 justify-center items-center">
        <div className="w-full cursor-pointer block p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100">
          <h5 className="mb-2 text-2xl font-bold tracking-tight text-gray-900">All Creations</h5>
        </div>
      </div>
    </div>
  );
};

export default ClassifierStore;
