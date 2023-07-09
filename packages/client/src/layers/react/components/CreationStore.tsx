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

export interface CreationStoreFilters {
  search: string;
  isMyCreation: boolean;
}

interface Props {
  layers: Layers;
  filters: CreationStoreFilters;
  setFilters: React.Dispatch<React.SetStateAction<CreationStoreFilters>>;
  setShowAllCreations: SetState<boolean>;
}

export interface Creation {
  name: string;
  description: string;
  creationId: Entity;
  creator: string;
  voxelTypes: string[];
  relativePositions: VoxelCoord[];
  numSpawns: BigInt;
  // voxelMetadata: string[];
}

const CreationStore: React.FC<Props> = ({ layers, filters, setFilters, setShowAllCreations }) => {
  const {
    noa: {
      components: { VoxelSelection, PersistentNotification, SpawnCreation, FocusedUi },
      SingletonEntity,
      noa,
    },
  } = layers;

  const { creationsToDisplay } = useCreationSearch({ layers, filters });

  const [registerNewCreation, setRegisterNewCreation] = useState<boolean>(false);

  const [registerCreationFormData, setRegisterCreationFormData] = useState<RegisterCreationFormData>({
    name: "",
    description: "",
  });

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
          <div className="flex w-full mt-5 justify-center items-center"></div>
        </>
      );
    }
  };

  const creationsNavClicked = () => {
    if (registerNewCreation) {
      resetRegisterCreationForm();
    } else {
      setShowAllCreations(false);
    }
  };

  const renderFooter = () => {
    if (registerNewCreation) {
      return null;
    }

    return (
      <div>
        <hr />
        <div className="flex w-full mt-5">
          <button
            type="button"
            onClick={() => setRegisterNewCreation(true)}
            className="py-2.5 px-5 mr-2 mb-2 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-200"
          >
            Register New Creation
          </button>
        </div>
      </div>
    );
  };

  return (
    <div className="flex flex-col h-full p-4 justify-between">
      <div>
        <nav className="flex" aria-label="Breadcrumb">
          <ol className="inline-flex items-center space-x-1 md:space-x-3">
            <li>
              <div className="flex items-center">
                <a
                  onClick={creationsNavClicked}
                  className="cursor-pointer text-sm font-medium text-gray-700 hover:text-blue-600 md:ml-2"
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
                <span className="ml-1 text-sm font-medium text-gray-500 md:ml-2">{getCurrentViewName()}</span>
              </div>
            </li>
          </ol>
        </nav>
        {renderMiddleContent()}
      </div>
      {renderFooter()}
    </div>
  );
};

export default CreationStore;
