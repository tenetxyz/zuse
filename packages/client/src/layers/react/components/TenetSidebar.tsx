import { useEffect, useState } from "react";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { VoxelTypeStore, VoxelTypeStoreFilters } from "./VoxelTypeStore";
import RegisterCreation, { RegisterCreationFormData } from "./RegisterCreation";
import { InventoryTab, TabRadioSelector } from "./TabRadioSelector";
import CreationStore, { CreationStoreFilters } from "./CreationStore";
import ClassifierStore, { ClassifierStoreFilters } from "./ClassifierStore";
import { ElectiveBar } from "./ElectiveBar";
import { setComponent } from "@latticexyz/recs";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { useComponentUpdate } from "../../../utils/useComponentUpdate";

export const SIDEBAR_BACKGROUND_COLOR = "#353535";
export function registerTenetSidebar() {
  registerTenetComponent({
    rowStart: 1,
    rowEnd: 12,
    columnStart: 1,
    columnEnd: 12,
    Component: ({ layers }) => {
      const {
        noa: {
          components: { FocusedUi },
          SingletonEntity,
        },
      } = layers;

      const [selectedTab, setSelectedTab] = useState<InventoryTab>(InventoryTab.NONE);

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

      const getPageForSelectedTab = () => {
        switch (selectedTab) {
          case InventoryTab.VOXEL_TYPE_STORE:
            return (
              <VoxelTypeStore
                layers={layers}
                filters={creativeInventoryFilters}
                setFilters={setCreativeInventoryFilters}
              />
            );
          case InventoryTab.REGISTER_CREATION:
            return (
              <RegisterCreation
                layers={layers}
                formData={registerCreationFormData}
                setFormData={setRegisterCreationFormData}
              />
            );
          case InventoryTab.CREATION_STORE:
            return (
              <CreationStore layers={layers} filters={creationStoreFilters} setFilters={setCreationStoreFilters} />
            );
          case InventoryTab.CLASSIFIER_STORE:
            return (
              <ClassifierStore
                layers={layers}
                filters={classifierStoreFilters}
                setFilters={setClassifierStoreFilters}
              />
            );
          case InventoryTab.NONE:
            return null;
        }
      };
      const SelectedTab = getPageForSelectedTab();

      useEffect(() => {
        if (selectedTab !== InventoryTab.NONE) {
          // the user clicked on the sidebar, so set the ui focus to the sidebar
          setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.SIDEBAR });
        }
      }, [selectedTab]);

      // type IFocusedUi = ComponentRecord<typeof FocusedUi>;
      useComponentUpdate(FocusedUi, (focusedUi) => {
        if (!focusedUi) {
          return;
        }
        if (focusedUi.value[0]?.value !== FocusedUiType.SIDEBAR) {
          setSelectedTab(InventoryTab.NONE);
        }
      });

      return (
        // "pointerEvents: all" is needed so when we click on the admin panel, we don't gain focus on the noa canvas
        <div className="h-full select-none" style={{ pointerEvents: "all" }}>
          <div
            className="flex flex-row float-left relative z-50 h-[80%] mt-[5%] pr-7 pt-7"
            style={{
              backgroundColor: selectedTab === InventoryTab.NONE ? "transparent" : `${SIDEBAR_BACKGROUND_COLOR}`,
            }}
          >
            <div className="flex flex-col">
              <TabRadioSelector selectedTab={selectedTab} setSelectedTab={setSelectedTab} />
              <ElectiveBar layers={layers} />
            </div>
            <div className={`bg-[${SIDEBAR_BACKGROUND_COLOR}]`}>{SelectedTab}</div>
          </div>
        </div>
      );
    },
  });
}
