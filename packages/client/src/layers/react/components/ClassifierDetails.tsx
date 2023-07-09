import React from "react";
import { Layers } from "../../../types";
import { Entity, getComponentValue, setComponent } from "@latticexyz/recs";
import { useCreationSearch } from "../../../utils/useCreationSearch";
import { useClassifierSearch } from "./useClassifierSearch";
import { CreationStoreFilters } from "./CreationStore";
import { useComponentValue } from "@latticexyz/react";
import { SetState } from "../../../utils/types";
import { entityToVoxelType, voxelTypeDataKeyToVoxelVariantDataKey, voxelTypeToEntity } from "../../noa/types";
import { stringToVoxelCoord } from "../../../utils/coord";
import { getSpawnAtPosition } from "../../../utils/voxels";
import { SearchBar } from "./common/SearchBar";
import { Classifier } from "./ClassifierStore";
import { twMerge } from "tailwind-merge";

export interface ClassifierStoreFilters {
  classifierQuery: string;
  creationFilter: CreationStoreFilters;
}

interface Props {
  layers: Layers;
  selectedClassifier: Classifier | null;
  setSelectedClassifier: SetState<Classifier | null>;
  setShowAllCreations: SetState<boolean>;
}

const ClassifierDetails: React.FC<Props> = ({
  layers,
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
      api: { getEntityAtPosition },
      getVoxelIconUrl,
    },
  } = layers;
  const spawnToUse = useComponentValue(SpawnToClassify, SingletonEntity);

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

  if (selectedClassifier === null) {
    return null;
  }

  const isSubmitDisabled = true;

  return (
    <div className="flex flex-col h-full mt-5 gap-5">
      <h4 className="text-2xl font-bold text-black">{selectedClassifier.name}</h4>
      <p className="font-normal text-gray-700 leading-4">{selectedClassifier.description}</p>
      <p className="font-normal text-gray-700 leading-4">
        <b>Creator:</b> {selectedClassifier.creator}
      </p>
      <button
        // onClick={handleSubmit}
        disabled={isSubmitDisabled}
        className={twMerge(
          "text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center",
          isSubmitDisabled ? "opacity-50 cursor-not-allowed" : ""
        )}
      >
        Submit Creation
      </button>
    </div>
  );
};

export default ClassifierDetails;
