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

  const getCurrentViewName = () => {
    return "";
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
    <div
      className="flex flex-col h-full p-4"
      style={{
        height: "calc(100% - 3rem)",
      }}
    >
      <div className="flex w-full">
        <SearchBar
          value={filters.classifierQuery}
          onChange={(e) => {
            setFilters({ ...filters, classifierQuery: e.target.value });
          }}
        />
      </div>
      <div className="flex w-full mt-5 flex-col items-center">
        <div
          onClick={() => setShowAllCreations(true)}
          className="w-full cursor-pointer block p-6 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-100"
        >
          <h5 className="mb-2 text-2xl font-bold tracking-tight text-gray-900">All Creations</h5>
        </div>
      </div>
      <nav className="flex mt-5" aria-label="Breadcrumb">
        <ol className="inline-flex items-center space-x-1 md:space-x-3">
          <li>
            <div className="flex items-center">
              <a
                // onClick={creationsNavClicked}
                className="cursor-pointer text-sm font-medium text-gray-700 hover:text-blue-600 md:ml-2"
              >
                Classifiers
              </a>
            </div>
          </li>
          <li aria-current="page">
            <div className="flex items-center">
              <svg
                className="w-3 h-3 text-gray-400 mx-1"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 6 10"
              >
                <path
                  stroke="currentColor"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="m1 9 4-4-4-4"
                />
              </svg>
              <span className="ml-1 text-sm font-medium text-gray-500 md:ml-2">{getCurrentViewName()}</span>
            </div>
          </li>
        </ol>
      </nav>
      <div className="flex w-full h-full mt-5 flex-col gap-5 items-center overflow-scroll">
        {classifiersToDisplay.map((classifier, idx) => {
          return (
            <div key={"classifier-" + idx} className="w-full p-6 bg-white border border-gray-200 rounded-lg shadow">
              <h5 className="mb-2 text-2xl font-bold tracking-tight text-gray-900">{classifier.name}</h5>
              <p className="font-normal text-gray-700 leading-4">{classifier.description}</p>
              <div className="flex mt-5 gap-2">
                <button
                  type="button"
                  className="text-gray-900 hover:text-white border border-gray-800 hover:bg-gray-900 focus:ring-4 focus:outline-none focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center mr-2 mb-2"
                >
                  View Details
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default ClassifierStore;
