import { useEffect, useState } from "react";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { VoxelTypeStore, VoxelTypeStoreFilters } from "./VoxelTypeStore";
import RegisterCreation, { RegisterCreationFormData } from "./RegisterCreation";
import { TabRadioSelector } from "./TabRadioSelector";
import CreationStore, { Creation, CreationStoreFilters } from "./CreationStore";
import ClassifierStore, { Classifier, ClassifierStoreFilters, CreationsPage } from "./ClassifierStore";
import { ElectiveBar } from "./ElectiveBar";
import { Entity, getComponentValue, getComponentValueStrict, setComponent } from "@latticexyz/recs";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { useComponentValue } from "@latticexyz/react";
import { twMerge } from "tailwind-merge";
import { TargetedBlock, getTargetedSpawnId } from "../../../utils/voxels";
import { stringToEntity } from "../../../utils/entity";
import { ISpawn } from "../../noa/components/SpawnInFocus";
import { WorldRegistry, WorldRegistryFilters } from "./WorldRegistry";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { abiDecode } from "@/utils/encodeOrDecode";
import { VoxelEntity } from "@/layers/noa/types";
import { parseCreationMetadata } from "@/utils/useCreationSearch";

enum SidebarTab {
  VOXELS = "Blocks",
  VOXEL_CREATIONS = "Creations",
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
          components: { Spawn },
          registryComponents: { CreationRegistry },
          worldAddress,
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
        scale: null,
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
      const [worldRegistryFilters, setWorldRegistryFilters] = useState<WorldRegistryFilters>({
        query: "",
      });

      const [selectedClassifier, setSelectedClassifier] = useState<Classifier | null>(null);
      const [selectedCreation, setSelectedCreation] = useState<Creation | null>(null);
      const [creationsPage, setCreationsPage] = useState<CreationsPage>(CreationsPage.CLASSIFIER_CREATIONS);

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

        const voxels = abiDecode("tuple(uint32 scale, bytes32 entityId)[]", rawSpawn.voxels) as VoxelEntity[];

        const spawn = {
          spawnId: stringToEntity(spawnId),
          creationId: stringToEntity(rawSpawn.creationId),
          lowerSouthWestCorner: abiDecode("tuple(int32 x,int32 y,int32 z)", rawSpawn.lowerSouthWestCorner),
          voxels,
        } as ISpawn;
        const creation = getComponentValueStrict(CreationRegistry, spawn.creationId);
        // TODO: use a function to parse the creation, rther than this hacky thing
        const { creator, name, description, numSpawns } = parseCreationMetadata(creation.metadata, worldAddress);
        creation.creator = creator;
        creation.name = creator;
        creation.description = creator;
        creation.numSpawns = creator;
        setComponent(SpawnInFocus, SingletonEntity, {
          spawn,
          creation,
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
            if (creationsPage === CreationsPage.ALL_CREATIONS) {
              return (
                <CreationStore
                  layers={layers}
                  filters={creationStoreFilters}
                  setFilters={setCreationStoreFilters}
                  setCreationsPage={setCreationsPage}
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
                creationsPage={creationsPage}
                setCreationsPage={setCreationsPage}
              />
            );
          case SidebarTab.WORLDS:
            return (
              <WorldRegistry layers={layers} filters={worldRegistryFilters} setFilters={setWorldRegistryFilters} />
            );
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
          style={{ pointerEvents: "all", background: "#24292E" }}
        >
          <div className="flex flex-col h-full">
            <div className="flex justify-center items-center w-full text-sm font-medium text-center text-gray-500">
              <ul
                className="flex flex-wrap rounded m-4 p-1 justify-between"
                style={{ pointerEvents: "all", background: "rgb(47, 53, 60)", width: "inherit" }}
              >
                {sidebarTabsArray.map((tab) => (
                  <li key={"tenet-sidebar-tab-" + tab} className="flex-grow text-center">
                    <a
                      onClick={() => setSelectedTab(tab)}
                      className={twMerge(
                        "block w-full px-4 py-1 rounded cursor-pointer",
                        selectedTab === tab
                          ? "text-gray-800 bg-slate-100 font-black"
                          : "text-gray-600 hover:text-gray-800 font-black"
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
