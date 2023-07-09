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

      const getPageForSelectedTab = () => {
        if (!focusedUi || !focusedUi.value) {
          return null;
        }
        switch (focusedUi.value) {
          case FocusedUiType.SIDEBAR_VOXEL_TYPE_STORE:
            return (
              <VoxelTypeStore
                layers={layers}
                filters={creativeInventoryFilters}
                setFilters={setCreativeInventoryFilters}
              />
            );
          case FocusedUiType.SIDEBAR_REGISTER_CREATION:
            return (
              <RegisterCreation
                layers={layers}
                formData={registerCreationFormData}
                setFormData={setRegisterCreationFormData}
              />
            );
          case FocusedUiType.SIDEBAR_CREATION_STORE:
            return (
              <CreationStore layers={layers} filters={creationStoreFilters} setFilters={setCreationStoreFilters} />
            );
          case FocusedUiType.SIDEBAR_CLASSIFY_STORE:
            return (
              <ClassifierStore
                layers={layers}
                filters={classifierStoreFilters}
                setFilters={setClassifierStoreFilters}
                selectedClassifier={selectedClassifier}
                setSelectedClassifier={setSelectedClassifier}
              />
            );
          default:
            return null;
        }
      };
      const SelectedTab = getPageForSelectedTab();

      const isFocusedUiASelectedTab =
        focusedUi &&
        focusedUi.value &&
        [
          FocusedUiType.SIDEBAR_VOXEL_TYPE_STORE,
          FocusedUiType.SIDEBAR_CREATION_STORE,
          FocusedUiType.SIDEBAR_CLASSIFY_STORE,
          FocusedUiType.SIDEBAR_REGISTER_CREATION,
        ].includes(focusedUi.value);

      return (
        <div
          style={{
            backgroundColor: "white",
            width: "100%",
            height: "100%",
            zIndex: "100",
          }}
        ></div>
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
