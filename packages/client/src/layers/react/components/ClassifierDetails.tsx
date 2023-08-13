import React from "react";
import { ComponentRecord, Layers } from "../../../types";
import { getComponentValue, removeComponent, setComponent } from "@latticexyz/recs";
import { CreationStoreFilters } from "./CreationStore";
import { useComponentValue } from "@latticexyz/react";
import { EMPTY_VOXEL_ENTITY, InterfaceVoxel, VoxelEntity, voxelEntityIsEmptyVoxel } from "../../noa/types";
import { voxelCoordToString } from "../../../utils/coord";
import { Classifier } from "./ClassifierStore";
import { twMerge } from "tailwind-merge";
import { ClassifierResults } from "./ClassifierResults";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { voxelEntityToEntity } from "../../../utils/entity";
import { TruthTableClassifierResults } from "./TruthTableClassifierResults";
import { toast } from "react-toastify";
import { TableInfo } from "./useClassifierSearch";

export interface ClassifierStoreFilters {
  classifierQuery: string;
  creationFilter: CreationStoreFilters;
}

interface Props {
  layers: Layers;
  selectedClassifier: Classifier | null;
}

const ClassifierDetails: React.FC<Props> = ({ layers, selectedClassifier }: Props) => {
  const {
    noa: {
      components: { FocusedUi, PersistentNotification, SpawnToClassify, SpawnInFocus, VoxelInterfaceSelection },
      SingletonEntity,
    },
    network: {
      components: { VoxelType, Position },
      api: { classifyCreation, classifyIfCreationSatisfiesTruthTable },
      getVoxelIconUrl,
    },
  } = layers;
  const spawnToUse = useComponentValue(SpawnToClassify, SingletonEntity);
  const spawnInFocus = useComponentValue(SpawnInFocus, SingletonEntity);

  type VoxelInterfaceSelectionRecord = ComponentRecord<typeof VoxelInterfaceSelection>;
  type FocusedUiRecord = ComponentRecord<typeof FocusedUi>;

  const selectInterfaceVoxel = (selectedVoxel: InterfaceVoxel) => {
    const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity);
    const allInterfaceVoxels =
      voxelSelection?.interfaceVoxels || (selectedClassifier ? selectedClassifier.selectorInterface : undefined);

    setComponent(VoxelInterfaceSelection, SingletonEntity, {
      interfaceVoxels: allInterfaceVoxels,
      selectingVoxelIdx: selectedVoxel.index,
    } as VoxelInterfaceSelectionRecord);
    setComponent(PersistentNotification, SingletonEntity, {
      message: "Press 'V' on a voxel to select it. Press Q when done.",
      icon: NotificationIcon.NONE,
    });
    setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.WORLD as any });
  };

  const cancelInterfaceSelection = (selectedVoxel: InterfaceVoxel) => {
    const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity);
    if (!voxelSelection || !voxelSelection.interfaceVoxels) {
      return;
    }
    const allInterfaceVoxels = voxelSelection.interfaceVoxels;
    allInterfaceVoxels[selectedVoxel.index] = {
      ...selectedVoxel,
      entity: EMPTY_VOXEL_ENTITY,
    };
    setComponent(VoxelInterfaceSelection, SingletonEntity, {
      interfaceVoxels: allInterfaceVoxels,
      selectingVoxelIdx: selectedVoxel.index,
    });
    setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.TENET_SIDEBAR as any });
  };

  const renderInterfaces = () => {
    if (!spawnToUse?.creation || !spawnToUse?.spawn) {
      return null;
    }

    if (!selectedClassifier) {
      return null;
    }

    const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity); // TODO: fix so we add scale

    return (
      <div className="flex flex-col">
        <h2 className="text-l font-bold text-white mb-5">Interfaces</h2>
        {selectedClassifier.selectorInterface.length === 0 && (
          <p className="font-normal text-gray-700 leading-4">This classifier requires no interfaces.</p>
        )}
        <div className="flex flex-col gap-5">
          {selectedClassifier.selectorInterface.map((interfaceVoxel, idx) => {
            console.log("interface voxel", interfaceVoxel);
            let selectedVoxel: VoxelEntity | undefined = undefined;
            if (voxelSelection && voxelSelection.interfaceVoxels) {
              selectedVoxel = voxelSelection.interfaceVoxels[interfaceVoxel.index]?.entity;
              if (!selectedVoxel || voxelEntityIsEmptyVoxel(selectedVoxel)) {
                selectedVoxel = undefined;
              }
            }

            return (
              <div className="flex flex-col" key={"interface-" + idx}>
                <label className="mb-1 text-sm font-normal text-gray-300">{interfaceVoxel.name}</label>
                <label className="mb-2 text-sm font-normal text-gray-300">{interfaceVoxel.desc}</label>
                <div className="flex">
                  <button
                    type="button"
                    onClick={() =>
                      selectedVoxel ? cancelInterfaceSelection(interfaceVoxel) : selectInterfaceVoxel(interfaceVoxel)
                    }
                    className="text-gray-400 hover:text-white border border-gray-800 hover:bg-gray-900 focus:ring-4 focus:outline-none focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center mr-2 mb-2"
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

  const renderInterfaceVoxelImage = (interfaceVoxel: VoxelEntity) => {
    if (!interfaceVoxel) {
      console.warn("Voxel not found at coord", interfaceVoxel);
      return null;
    }
    const voxelEntityKey = voxelEntityToEntity(interfaceVoxel);
    const voxelType = getComponentValue(VoxelType, voxelEntityKey);
    if (!voxelType) {
      console.warn("Voxel type not found for voxel", interfaceVoxel);
      return null;
    }

    const iconUrl = getVoxelIconUrl(voxelType.voxelVariantId);
    const voxelCoord = getComponentValue(Position, voxelEntityKey);
    return (
      <div className="flex gap-2 items-center">
        <div className="bg-slate-100 h-fit p-1">
          <img src={iconUrl} className="w-[32px] h-[32px]" />
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
        if (voxelEntityIsEmptyVoxel(interfaceVoxel.entity)) {
          return true;
        }
      }
    }

    return false;
  };

  const onClassifySuccess = (txHash: string) => {
    removeComponent(VoxelInterfaceSelection, SingletonEntity);
    removeComponent(SpawnToClassify, SingletonEntity);
    toast("The creation passes the classifier!");
  };

  const isClassifierTruthTable = selectedClassifier.namespace === "tenet-truth-table";

  const onSubmit = () => {
    const voxelSelection = getComponentValue(VoxelInterfaceSelection, SingletonEntity);
    if (isClassifierTruthTable) {
      // special case for tenet classifiers
      classifyIfCreationSatisfiesTruthTable(
        selectedClassifier.classifierId,
        spawnToUse!.spawn!.spawnId,
        voxelSelection?.interfaceVoxels || [],
        onClassifySuccess
      );
    } else {
      classifyCreation(
        selectedClassifier.classifierId,
        spawnToUse!.spawn!.spawnId, // the spawn must exist if the submit button is enabled (and pressed)
        voxelSelection?.interfaceVoxels || [],
        onClassifySuccess
      );
    }
  };

  return (
    <div className="flex flex-col h-full mt-5 gap-5 overflow-y-auto">
      <h4 className="text-2xl font-bold text-white">{selectedClassifier.name}</h4>
      <p className="font-normal text-gray-200 leading-4">{selectedClassifier.description}</p>
      <p className="font-normal text-gray-300 leading-4">
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
        onClick={onSubmit}
        disabled={isSubmitDisabled()}
        className={twMerge(
          "text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center",
          isSubmitDisabled() ? "opacity-50 cursor-not-allowed" : ""
        )}
      >
        Submit Creation
      </button>
      <div>
        {isClassifierTruthTable && (
          <div>
            <p className="mb-8">Truth Table</p>
            {renderTruthTable(selectedClassifier.truthTableInfo!)}
          </div>
        )}
      </div>

      <hr className="h-0.5 bg-gray-300 mt-4 mb-4 border-0" />
      <h3 className="text-xl font-bold">Submissions</h3>
      {isClassifierTruthTable ? (
        <TruthTableClassifierResults layers={layers} classifier={selectedClassifier} />
      ) : (
        <ClassifierResults layers={layers} classifier={selectedClassifier} />
      )}
    </div>
  );
};

const renderTruthTable = (tableInfo: TableInfo) => {
  const headers = () => {
    const res = [];
    for (let i = 0; i < tableInfo.numInputBits; i++) {
      res.push(
        <th scope="col" className="px-2 py-3">
          In{i}
        </th>
      );
    }
    for (let i = 0; i < tableInfo.numOutputBits; i++) {
      res.push(
        <th scope="col" className="px-2 py-3">
          Out{i}
        </th>
      );
    }
    return res;
  };

  const truthTableRow = (rowIdx: number) => {
    const res = [];
    const inputRow = tableInfo.inputRows[rowIdx].padStart(tableInfo.numInputBits, "0");
    const outputRow = tableInfo.outputRows[rowIdx].padStart(tableInfo.numOutputBits, "0");
    for (let i = 0; i < tableInfo.numInputBits; i++) {
      res.push(<td className="px-2 py-2 whitespace-nowrap w-2">{inputRow[i]}</td>);
    }
    for (let i = 0; i < tableInfo.numOutputBits; i++) {
      res.push(<td className="px-2 py-2 whitespace-nowrap w-2">{outputRow[i]}</td>); // Added w-4 here
    }
    return res;
  };

  return (
    <div className="relative overflow-x-auto">
      <table className="w-full text-sm text-left text-gray-500 m-2">
        <thead className="text-xs text-gray-700 uppercase bg-gray-50">
          <tr>{headers()}</tr>
        </thead>
        <tbody>
          {tableInfo.inputRows.map((_result, index) => (
            <tr key={"creation-" + index} className="bg-white border-b">
              {truthTableRow(index)}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default ClassifierDetails;
