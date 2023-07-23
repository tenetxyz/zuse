import { useEffect, useState } from "react";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { VoxelTypeStore, VoxelTypeStoreFilters } from "./VoxelTypeStore";
import RegisterCreation, { RegisterCreationFormData } from "./RegisterCreation";
import { TabRadioSelector } from "./TabRadioSelector";
import CreationStore, { Creation, CreationStoreFilters } from "./CreationStore";
import ClassifierStore, { Classifier, ClassifierStoreFilters } from "./ClassifierStore";
import { ElectiveBar } from "./ElectiveBar";
import { Entity, getComponentValue, setComponent } from "@latticexyz/recs";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { useComponentUpdate } from "../../../utils/useComponentUpdate";
import { useComponentValue } from "@latticexyz/react";
import { twMerge } from "tailwind-merge";
import { TargetedBlock, getTargetedSpawnId } from "../../../utils/voxels";
import { stringToEntity } from "../../../utils/entity";
import { abiDecode } from "../../../utils/abi";
import { ISpawn } from "../../noa/components/SpawnInFocus";
import { WorldRegistry } from "./WorldsRegistry";

enum SidebarTab {
  VOXELS = "Voxel Types",
  VOXEL_CREATIONS = "Voxel Creations",
  WORLDS = "Worlds",
}

// Convert enum values to an array
const sidebarTabsArray = Object.values(SidebarTab);

export const SIDEBAR_BACKGROUND_COLOR = "#353535";
export function registerTenetSidebar() {
  registerTenetComponent({
    rowStart: 1,
    rowEnd: 13,
    columnStart: 1,
    columnEnd: 5,
    zIndex: 100,
    Component: ({ layers }) => {
      const {
        noa: {
          noa,
          components: { FocusedUi, SpawnInFocus },
          SingletonEntity,
        },
        network: {
          components: { Spawn, Creation },
        },
      } = layers;

      const [selectedTab, setSelectedTab] = useState<SidebarTab>(SidebarTab.VOXELS);

      const focusedUi = useComponentValue(FocusedUi, SingletonEntity);

      const [registerCreationFormData, setRegisterCreationFormData] = useState<RegisterCreationFormData>({
        name: "",
        description: "",
      });

      // This state is hoisted up to this component so that the state is not lost when leaving the inventory to select voxels
      const [creativeInventoryFilters, setCreativeInventoryFilters] = useState<VoxelTypeStoreFilters>({
        query: "",
      });
      const [creationStoreFilters, setCreationStoreFilters] = useState<CreationStoreFilters>({
        search: "",
        isMyCreation: false,
      });
      const [classifierStoreFilters, setClassifierStoreFilters] = useState<ClassifierStoreFilters>({
        classifierQuery: "",
        creationFilter: {
          search: "",
          isMyCreation: true,
        },
      });

      const [selectedClassifier, setSelectedClassifier] = useState<Classifier | null>(null);
      const [selectedCreation, setSelectedCreation] = useState<Creation | null>(null);
      const [showAllCreations, setShowAllCreations] = useState<boolean>(false);

      useEffect(() => {
        noa.on("targetBlockChanged", getSpawnUserIsLookingAt);
      }, []);

      const getSpawnUserIsLookingAt = (targetedBlock: TargetedBlock) => {
        const spawnId = getTargetedSpawnId(layers, targetedBlock);
        if (!spawnId) {
          // The user is not looking at any spawn. so clear the spawn in focus
          const currentSpawnInFocus = getComponentValue(SpawnInFocus, SingletonEntity);
          if (currentSpawnInFocus) {
            setComponent(SpawnInFocus, SingletonEntity, { spawn: undefined, creation: undefined });
          }
          return;
        }

        const rawSpawn = getComponentValue(Spawn, stringToEntity(spawnId));
        if (!rawSpawn) {
          console.error("cannot find spawn object with spawnId=", spawnId);
          return;
        }

        const spawn = {
          spawnId: stringToEntity(spawnId),
          creationId: stringToEntity(rawSpawn.creationId),
          lowerSouthWestCorner: abiDecode("tuple(int32 x,int32 y,int32 z)", rawSpawn.lowerSouthWestCorner),
          voxels: rawSpawn.voxels as Entity[],
        } as ISpawn;
        const creation = getComponentValue(Creation, spawn.creationId);
        setComponent(SpawnInFocus, SingletonEntity, {
          spawn: spawn,
          creation: creation,
        });
      };

      const getPageForSelectedTab = () => {
        if (!focusedUi || !focusedUi.value) {
          return null;
        }
        switch (selectedTab) {
          case SidebarTab.VOXELS:
            return (
              <VoxelTypeStore
                layers={layers}
                filters={creativeInventoryFilters}
                setFilters={setCreativeInventoryFilters}
              />
            );
          case SidebarTab.VOXEL_CREATIONS:
            if (showAllCreations) {
              return (
                <CreationStore
                  layers={layers}
                  filters={creationStoreFilters}
                  setFilters={setCreationStoreFilters}
                  setShowAllCreations={setShowAllCreations}
                  selectedCreation={selectedCreation}
                  setSelectedCreation={setSelectedCreation}
                  registerCreationFormData={registerCreationFormData}
                  setRegisterCreationFormData={setRegisterCreationFormData}
                />
              );
            }

            return (
              <ClassifierStore
                layers={layers}
                filters={classifierStoreFilters}
                setFilters={setClassifierStoreFilters}
                selectedClassifier={selectedClassifier}
                setSelectedClassifier={setSelectedClassifier}
                setShowAllCreations={setShowAllCreations}
              />
            );
          case SidebarTab.WORLDS:
            return <WorldRegistry />;
          default:
            return null;
        }
      };
      const SelectedTabPage = getPageForSelectedTab();

      const showSidebar = focusedUi && focusedUi.value === FocusedUiType.TENET_SIDEBAR;

      return (
        <div
          className={twMerge(
            `bg-white w-full h-full transition duration-500`,
            showSidebar ? "translate-x-0 opacity-100" : "-translate-x-full opacity-0"
          )}
          // "pointerEvents: all" is needed so when we click on the admin panel, we don't gain focus on the noa canvasvoxelTypes = creationTable.voxelTypes.get(creationId)
          style={{ pointerEvents: "all" }}
        >
          <div className="flex flex-col h-full">
            <div className="flex justify-center items-center w-full text-sm font-medium text-center text-gray-500 border-b border-gray-200">
              <ul className="flex flex-wrap -mb-px">
                {sidebarTabsArray.map((tab) => (
                  <li className="mr-2" key={"tenet-sidebar-tab-" + tab}>
                    <a
                      onClick={() => setSelectedTab(tab)}
                      className={twMerge(
                        "inline-block p-4 border-b-2 rounded-t-lg cursor-pointer",
                        selectedTab === tab
                          ? "text-blue-600 border-blue-600 active"
                          : "border-transparent hover:text-gray-600 hover:border-gray-300"
                      )}
                    >
                      {tab}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
            {SelectedTabPage}
          </div>
        </div>
      );
    },
  });
}
