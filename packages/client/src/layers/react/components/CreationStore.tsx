import React, { useState } from "react";
import { Layers } from "../../../types";
import { Entity, setComponent } from "@latticexyz/recs";
import { VoxelCoord } from "@latticexyz/utils";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import { useCreationSearch } from "../../../utils/useCreationSearch";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { SearchBar } from "./common/SearchBar";
import { SetState } from "../../../utils/types";
import RegisterCreation, { RegisterCreationFormData } from "./RegisterCreation";
import CreationDetails from "./CreationDetails";
import { VoxelTypeKey } from "../../noa/types";
import { BaseCreation } from "../../noa/systems/createSpawnOverlaySystem";
import { Separator } from "@/components/ui/separator";
import { CreationsPage } from "./ClassifierStore";

export interface CreationStoreFilters {
  search: string;
  isMyCreation: boolean;
}

interface Props {
  layers: Layers;
  filters: CreationStoreFilters;
  setFilters: React.Dispatch<React.SetStateAction<CreationStoreFilters>>;
  setCreationsPage: SetState<CreationsPage>;
  selectedCreation: Creation | null;
  setSelectedCreation: SetState<Creation | null>;
  registerCreationFormData: RegisterCreationFormData;
  setRegisterCreationFormData: SetState<RegisterCreationFormData>;
}

export interface Creation {
  name: string;
  description: string;
  creationId: Entity;
  creator: string;
  voxelTypes: VoxelTypeKey[];
  relativePositions: VoxelCoord[];
  numSpawns: BigInt;
  numVoxels: number;
  // voxelMetadata: string[];
  baseCreations: BaseCreation[];
}

const CreationStore: React.FC<Props> = ({
  layers,
  filters,
  setFilters,
  setCreationsPage,
  selectedCreation,
  setSelectedCreation,
  registerCreationFormData,
  setRegisterCreationFormData,
}) => {
  const {
    noa: {
      components: { VoxelSelection, PersistentNotification, SpawnCreation, FocusedUi },
      SingletonEntity,
      noa,
    },
  } = layers;

  const { creationsToDisplay } = useCreationSearch({ layers, filters });

  const [registerNewCreation, setRegisterNewCreation] = useState<boolean>(false);

  const resetRegisterCreationForm = () => {
    setRegisterCreationFormData({ name: "", description: "" });
    setComponent(VoxelSelection, SingletonEntity, {
      corner1: undefined,
      corner2: undefined,
    } as any);
    setRegisterNewCreation(false);
  };

  const spawnCreation = (creation: Creation) => {
    setComponent(PersistentNotification, SingletonEntity, {
      message: "press 'Enter' to place creation, 'backspace' to cancel",
      icon: NotificationIcon.NONE,
    });
    setComponent(SpawnCreation, SingletonEntity, {
      creation: creation,
    });
    noa.blockTestDistance = 30; // increase the distance so placing creations is easier for players
    setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.WORLD });
  };

  const getCurrentViewName = () => {
    if (registerNewCreation) {
      return "New Creation";
    } else if (selectedCreation !== null) {
      return selectedCreation.name;
    } else {
      return "All Creations";
    }
  };

  const renderMiddleContent = () => {
    if (registerNewCreation) {
      return (
        <RegisterCreation
          layers={layers}
          formData={registerCreationFormData}
          setFormData={setRegisterCreationFormData}
          resetRegisterCreationForm={resetRegisterCreationForm}
        />
      );
    } else if (selectedCreation !== null) {
      return <CreationDetails layers={layers} selectedCreation={selectedCreation} />;
    } else {
      return (
        <>
          <div className="flex w-full mt-5">
            <SearchBar
              value={filters.search}
              onChange={(e) => {
                setFilters({ ...filters, search: e.target.value });
              }}
            />
          </div>
          <div className="flex flex-col gap-5 mt-5 mb-4 w-full h-full justify-start items-center overflow-scroll">
            {creationsToDisplay.map((creation, idx) => {
              return (
                <div key={"creation-" + idx} style={{ border: "1px solid #374147" }} className="w-full p-6 rounded">
                  <div className="flex justify-between items-center mb-4">
                    <h5 className="font-black tracking-tight">{creation.name}</h5>
                    <span className="inline-block bg-slate-600 rounded-full px-2 py-0 text-xs text-slate-200">
                      Spawns: {creation.numSpawns.toString()}
                    </span>
                  </div>
                  <p className="font-light text-xs">{creation.description}</p>
                  <div className="flex mt-5 gap-2">
                    <button
                      type="button"
                      onClick={(event) => {
                        (event.target as HTMLElement).blur();
                        spawnCreation(creation);
                      }}
                      className="py-2.5 px-5 mr-2 text-sm font-bold rounded bg-amber-400 hover:bg-amber-500 text-slate-600"
                    >
                      Spawn
                    </button>
                    <button
                      type="button"
                      onClick={() => setSelectedCreation(creation)}
                      className="py-2.5 px-5 mr-2 text-sm font-bold rounded border border-amber-400 hover:bg-slate-600 text-amber-400"
                    >
                      View Details
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        </>
      );
    }
  };

  const creationsNavClicked = () => {
    if (registerNewCreation) {
      resetRegisterCreationForm();
    } else if (selectedCreation != null) {
      setSelectedCreation(null);
    } else {
      setCreationsPage(CreationsPage.CLASSIFIER_CREATIONS);
    }
  };

  const renderFooter = () => {
    if (registerNewCreation || selectedCreation !== null) {
      return null;
    }

    return (
      <div className="flex w-full">
        <button
          type="button"
          onClick={() => setRegisterNewCreation(true)}
          className="py-2.5 px-5 mr-2 text-sm font-bold rounded bg-amber-400 hover:bg-amber-500 text-slate-600"
        >
          Register New Creation
        </button>
      </div>
    );
  };

  return (
    <div
      className="flex flex-col p-4"
      style={{
        height: "calc(100% - 3rem)",
      }}
    >
      <nav className="flex" aria-label="Breadcrumb">
        <ol className="inline-flex items-center space-x-1 md:space-x-3">
          <li>
            <div className="flex items-center">
              <a
                onClick={creationsNavClicked}
                className="cursor-pointer text-sm font-medium text-gray-700 hover:text-slate-500"
              >
                Creations
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
              <span className="ml-1 text-sm font-medium text-gray-500">{getCurrentViewName()}</span>
            </div>
          </li>
        </ol>
      </nav>
      {renderMiddleContent()}
      <Separator className="my-4" style={{ background: "#374147" }} />
      {renderFooter()}
    </div>
  );
};

export default CreationStore;
