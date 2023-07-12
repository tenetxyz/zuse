import React, { useEffect } from "react";
import { Layers } from "../../../types";
import { Entity, getComponentValue, removeComponent, setComponent } from "@latticexyz/recs";
import { useCreationSearch } from "../../../utils/useCreationSearch";
import { useClassifierSearch } from "./useClassifierSearch";
import { CreationStoreFilters } from "./CreationStore";
import { useComponentValue } from "@latticexyz/react";
import { SetState } from "../../../utils/types";
import {
  EMPTY_BYTES_32,
  InterfaceVoxel,
  entityToVoxelType,
  voxelTypeDataKeyToVoxelVariantDataKey,
  voxelTypeToEntity,
} from "../../noa/types";
import { stringToVoxelCoord, voxelCoordToString } from "../../../utils/coord";
import { getSpawnAtPosition } from "../../../utils/voxels";
import { SearchBar } from "./common/SearchBar";
import { Classifier } from "./ClassifierStore";
import { twMerge } from "tailwind-merge";
import { stringToEntity } from "../../../utils/entity";
import { abiDecode } from "../../../utils/abi";
import { ISpawn } from "../../noa/components/SpawnInFocus";
import { ClassifierResults } from "./ClassifierResults";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import { FocusedUiType } from "../../noa/components/FocusedUi";

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
      noa,
      components: {
        FocusedUi,
        PersistentNotification,
        SpawnToClassify,
        VoxelSelection,
        SpawnInFocus,
        VoxelInterfaceSelection,
      },
      SingletonEntity,
    },
    network: {
      components: { Position, VoxelType, OfSpawn, Spawn, Creation },
      api: { getEntityAtPosition, classifyCreation },
      getVoxelIconUrl,
    },
  } = layers;
  const spawnToUse = useComponentValue(SpawnToClassify, SingletonEntity);
  const spawnInFocus = useComponentValue(SpawnInFocus, SingletonEntity);

  const selectInterfaceVoxel = (selectedVoxel: InterfaceVoxel) => {
    const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity);
    const allInterfaceVoxels =
      voxelSelection?.interfaceVoxels || (selectedClassifier && selectedClassifier.selectorInterface);
    setComponent(VoxelInterfaceSelection, SingletonEntity, {
      interfaceVoxels: allInterfaceVoxels,
      selectingVoxelIdx: selectedVoxel.index,
    });
    setComponent(PersistentNotification, SingletonEntity, {
      message: "Press 'V' on a voxel to select it. Press - when done.",
      icon: NotificationIcon.NONE,
    });
    setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.WORLD });
  };

  const cancelInterfaceSelection = (selectedVoxel: InterfaceVoxel) => {
    const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity);
    if (!voxelSelection || !voxelSelection.interfaceVoxels) {
      return;
    }
    const allInterfaceVoxels = voxelSelection.interfaceVoxels;
    allInterfaceVoxels[selectedVoxel.index] = {
      ...selectedVoxel,
      entity: EMPTY_BYTES_32,
    };
    setComponent(VoxelInterfaceSelection, SingletonEntity, {
      interfaceVoxels: allInterfaceVoxels,
      selectingVoxelIdx: selectedVoxel.index,
    });
    setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.TENET_SIDEBAR });
  };

  const renderInterfaces = () => {
    if (!spawnToUse?.creation || !spawnToUse?.spawn) {
      return null;
    }

    if (!selectedClassifier) {
      return null;
    }

    const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity);

    return (
      <div className="flex flex-col">
        <h2 className="text-l font-bold text-black mb-5">Interfaces</h2>
        {selectedClassifier.selectorInterface.length === 0 && (
          <p className="font-normal text-gray-700 leading-4">This classifier requires no interfaces.</p>
        )}
        <div className="flex flex-col gap-5">
          {selectedClassifier.selectorInterface.map((interfaceVoxel, idx) => {
            let selectedVoxel: Entity | undefined = undefined;
            if (voxelSelection && voxelSelection.interfaceVoxels) {
              selectedVoxel = voxelSelection.interfaceVoxels[interfaceVoxel.index].entity;
              if (selectedVoxel === EMPTY_BYTES_32) {
                selectedVoxel = undefined;
              }
            }

            return (
              <div className="flex flex-col" key={"interface-" + idx}>
                <label className="mb-1 text-sm font-normal text-gray-900">{interfaceVoxel.name}</label>
                <label className="mb-2 text-sm font-normal text-gray-700">{interfaceVoxel.desc}</label>
                <div className="flex">
                  <button
                    type="button"
                    onClick={() =>
                      selectedVoxel ? cancelInterfaceSelection(interfaceVoxel) : selectInterfaceVoxel(interfaceVoxel)
                    }
                    className="text-gray-900 hover:text-white border border-gray-800 hover:bg-gray-900 focus:ring-4 focus:outline-none focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center mr-2 mb-2"
                  >
                    {selectedVoxel ? "Cancel Selection" : "Select Voxel"}
                  </button>
                  {selectedVoxel && renderInterfaceVoxelImage(selectedVoxel)}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    );
  };

  const renderInterfaceVoxelImage = (interfaceVoxel: Entity) => {
    if (!interfaceVoxel) {
      console.warn("Voxel not found at coord", interfaceVoxel);
      return null;
    }
    const voxelType = getComponentValue(VoxelType, interfaceVoxel);
    if (!voxelType) {
      console.warn("Voxel type not found for voxel", interfaceVoxel);
      return null;
    }

    const iconKey = voxelTypeDataKeyToVoxelVariantDataKey(voxelType);
    const iconUrl = getVoxelIconUrl(iconKey);
    const voxelCoord = getComponentValue(Position, interfaceVoxel);
    return (
      <div className="flex gap-2 items-center">
        <div className="bg-slate-100 h-fit p-1">
          <img src={iconUrl} />
        </div>
        <span className="text-black">at {voxelCoord && voxelCoordToString(voxelCoord)}</span>
      </div>
    );
  };

  if (selectedClassifier === null) {
    return null;
  }

  const onSelectSpawn = () => {
    if (spawnToUse && spawnToUse.creation) {
      setComponent(SpawnToClassify, SingletonEntity, { spawn: undefined, creation: undefined });
    } else if (spawnInFocus && spawnInFocus.creation) {
      setComponent(SpawnToClassify, SingletonEntity, { spawn: spawnInFocus.spawn, creation: spawnInFocus.creation });
    } else {
      setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.WORLD });
    }
  };

  const getSelectSpawnButtonLabel = () => {
    if (spawnToUse && spawnToUse.creation) {
      return (
        <>
          <p className="font-medium">Selected Creation: {spawnToUse?.creation?.name}</p>
          <p className="mt-2 text-gray-500">Click here to cancel selection</p>
        </>
      );
    } else if (spawnInFocus && spawnInFocus.creation) {
      return (
        <>
          <p>Click to Confirm Selected Creation:</p>
          <p className="mt-2">{spawnInFocus?.creation?.name}</p>
        </>
      );
    } else {
      return "Look at a creation in the world to select it";
    }
  };

  const isSubmitDisabled = () => {
    if (spawnToUse === undefined || !spawnToUse.creation) {
      return true;
    }

    if (selectedClassifier.selectorInterface.length > 0) {
      const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity);
      if (!voxelSelection || !voxelSelection.interfaceVoxels) {
        return true;
      }

      for (let i = 0; i < voxelSelection.interfaceVoxels.length; i++) {
        const interfaceVoxel = voxelSelection.interfaceVoxels[i];
        if (interfaceVoxel.entity === EMPTY_BYTES_32) {
          return true;
        }
      }
    }

    return false;
  };

  return (
    <div className="flex flex-col h-full mt-5 gap-5">
      <h4 className="text-2xl font-bold text-black">{selectedClassifier.name}</h4>
      <p className="font-normal text-gray-700 leading-4">{selectedClassifier.description}</p>
      <p className="font-normal text-gray-700 leading-4">
        <b>Creator:</b> {selectedClassifier.creator}
      </p>
      <button
        type="button"
        onClick={onSelectSpawn}
        className="py-2.5 px-5 mr-2 mb-2 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-200"
      >
        {getSelectSpawnButtonLabel()}
      </button>
      {renderInterfaces()}
      <button
        onClick={() => {
          const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity);
          classifyCreation(
            selectedClassifier.classifierId,
            spawnToUse.spawn.spawnId,
            voxelSelection?.interfaceVoxels || [],
            (txHash: string) => {
              removeComponent(VoxelInterfaceSelection, SingletonEntity);
              removeComponent(SpawnToClassify, SingletonEntity);
            }
          );
        }}
        disabled={isSubmitDisabled()}
        className={twMerge(
          "text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center",
          isSubmitDisabled() ? "opacity-50 cursor-not-allowed" : ""
        )}
      >
        Submit Creation
      </button>
      <hr className="h-0.5 bg-gray-300 mt-4 mb-4 border-0" />
      <h3 className="text-xl font-bold text-black">Submissions</h3>
      <ClassifierResults layers={layers} classifier={selectedClassifier} />
    </div>
  );
};

export default ClassifierDetails;
