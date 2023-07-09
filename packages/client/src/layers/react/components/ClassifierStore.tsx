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
import { getSpawnAtPosition } from "../../../utils/voxels";
import { SearchBar } from "./common/SearchBar";

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
  setShowAllCreations: SetState<boolean>;
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
  setShowAllCreations,
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
        <SearchBar
          value={filters.classifierQuery}
          onChange={(e) => {
            setFilters({ ...filters, classifierQuery: e.target.value });
          }}
        />
      </div>
      <div className="flex w-full mt-5 justify-center items-center">
        <div
          onClick={() => setShowAllCreations(true)}
          className="w-full cursor-pointer block p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100"
        >
          <h5 className="mb-2 text-2xl font-bold tracking-tight text-gray-900">All Creations</h5>
        </div>
      </div>
    </div>
  );
};

export default ClassifierStore;
