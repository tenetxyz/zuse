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
import { cacheStore$ } from "@latticexyz/network/dev";

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
      api: { getEntityAtPosition },
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

  cacheStore$.subscribe((storeEvent) => {
    console.log("store event", storeEvent);
    // TODO: narrow down to the chain/world we care about?
  });

  const detailsForSpawnToClassify = () => {
    if (!spawnToUse?.creation || !spawnToUse?.spawn) {
      return <p>Please look at a spawn of a creation and press the button to classify it</p>;
    }

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
        return interfaceSpawnId === spawnToUse.spawn.spawnId;
      });

    //   const cacheStoreKeys = Array.from(cacheStore.state.keys()).filter((key) => {
    //     const [component] = unpackTuple(key);
    //     return component === componentIndex;
    //   });
    // }

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
            // the interface voxels are defined above
            alert("todo: submit creation to classifier");
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
    <div className="mx-auto p-4 text-white flex flex-row content-start float-top h-full min-w-[800px]">
      {/* <div className="flex flex-col">
        <label className="flex items-center space-x-2 ml-2">My Creations</label>
        <div className="flex flex-row">
          <input
            placeholder="Search My Creations"
            className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
            value={filters.creationFilter.search}
            onChange={(e) => {
              setFilters({
                ...filters,
                creationFilter: {
                  ...filters.creationFilter,
                  search: e.target.value,
                },
              });
            }}
          />
        </div>
        <div className="m-2 p-2 flex flex-col">
          {creationsToDisplay.map((creation, idx) => {
            return (
              <div
                key={idx}
                className="border-1 border-solid border-slate-700 p-2 mb-2 flex flex-row whitespace-nowrap justify-around break-all space-x-5"
              >
                <p>{creation.name}</p>
                <p>{creation.description}</p>
                <p className="">{creation.relativePositions.length} voxels</p>
                <p className="break-all break-words">{creation.creator.substr(50)}</p>
              </div>
            );
          })}
        </div>
      </div> */}
      <div className="flex flex-col">
        <label className="flex items-center space-x-2 ml-2">Classifiers</label>
        <input
          placeholder="Search classifiers"
          className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
          value={filters.classifierQuery}
          onChange={(e) => {
            setFilters({ ...filters, classifierQuery: e.target.value });
          }}
        />
        <div className="m-2 p-2 flex flex-col">
          {classifiersToDisplay.map((classifier, idx) => {
            return (
              <div
                key={idx}
                className="border-1 border-solid border-slate-700 p-2 mb-2 flex flex-row whitespace-nowrap break-all justify-around space-x-5"
                onClick={() => {
                  setSelectedClassifier(classifier);
                }}
              >
                <p>{classifier.name}</p>
                <p>{classifier.description}</p>
                <p className="break-all break-words">{classifier.creator.substring(10)}</p>
              </div>
            );
          })}
        </div>
      </div>
      <div>
        {selectedClassifier && (
          <div className="flex flex-col">
            <label className="flex items-center space-x-2 ml-2">Selected Classifier</label>
            <div className="border-1 border-solid border-slate-700 p-2 mb-2 flex flex-row whitespace-nowrap break-all justify-around space-x-5">
              <p>{selectedClassifier.name}</p>
              <p>{selectedClassifier.description}</p>
              <p className="break-all break-words">{selectedClassifier.creator.substring(10)}</p>
            </div>
            {detailsForSpawnToClassify()}
          </div>
        )}
      </div>
    </div>
  );
};

export default ClassifierStore;
