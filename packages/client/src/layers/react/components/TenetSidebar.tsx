import { useEffect, useState } from "react";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { VoxelTypeStore, VoxelTypeStoreFilters } from "./VoxelTypeStore";
import RegisterCreation, { RegisterCreationFormData } from "./RegisterCreation";
import { TabRadioSelector } from "./TabRadioSelector";
import CreationStore, { CreationStoreFilters } from "./CreationStore";
import ClassifierStore, { Classifier, ClassifierStoreFilters } from "./ClassifierStore";
import { ElectiveBar } from "./ElectiveBar";
import { setComponent } from "@latticexyz/recs";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { useComponentUpdate } from "../../../utils/useComponentUpdate";
import { useComponentValue } from "@latticexyz/react";
import { twMerge } from "tailwind-merge";

enum SidebarTab {
  VOXELS = "Voxel Types",
  VOXEL_CREATIONS = "Voxel Creations",
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
          components: { FocusedUi },
          SingletonEntity,
        },
      } = layers;

      const [selectedTab, setSelectedTab] = useState<SidebarTab>(SidebarTab.VOXELS);

      const focusedUi = useComponentValue(FocusedUi, SingletonEntity);

      // This state is hoisted up to this component so that the state is not lost when leaving the inventory to select voxels
      const [creativeInventoryFilters, setCreativeInventoryFilters] = useState<VoxelTypeStoreFilters>({
        query: "",
      });
      const [registerCreationFormData, setRegisterCreationFormData] = useState<RegisterCreationFormData>({
        name: "",
        description: "",
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
      const [showAllCreations, setShowAllCreations] = useState<boolean>(false);

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
                <CreationStore layers={layers} filters={creationStoreFilters} setFilters={setCreationStoreFilters} />
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
          style={{ pointerEvents: "all" }}
        >
          <div className="flex flex-col">
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
            <div>{SelectedTabPage}</div>
          </div>
        </div>
      );
    },
  });
}

// "pointerEvents: all" is needed so when we click on the admin panel, we don't gain focus on the noa canvas
// <div className="select-none h-full inline-grid" style={{ pointerEvents: "all" }}>

/* <div
            className="flex flex-row float-left relative z-50 mt-[5%] pr-7 pt-7"
            style={{
              backgroundColor: isFocusedUiASelectedTab ? `${SIDEBAR_BACKGROUND_COLOR}` : "transparent",
            }}
          >
            <div className="flex flex-col">
              <TabRadioSelector layers={layers} />
              <ElectiveBar layers={layers} />
            </div>
            <div className={`bg-[${SIDEBAR_BACKGROUND_COLOR}]`}>{SelectedTab}</div>
          </div> */

// </div>
