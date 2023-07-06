import { useState } from "react";
import { registerTenetComponent } from "./engine/components/TenetComponentRenderer";
import { useComponentValue } from "@latticexyz/react";
import { VoxelTypeStore, VoxelTypeStoreFilters } from "./components/VoxelTypeStore";
import RegisterCreation, { RegisterCreationFormData } from "./components/RegisterCreation";
import { InventoryTab, TabRadioSelector } from "./components/TabRadioSelector";
import CreationStore, { CreationStoreFilters } from "./components/CreationStore";
import { Absolute, AbsoluteBorder, Background, Center } from "./components";
import styled from "styled-components";
import ClassifierStore from "./components/ClassifierStore";

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
          components: { UI },
          SingletonEntity,
          noa,
        },
        network: {
          contractComponents: { VoxelTypeRegistry },
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

      return (
        // "pointerEvents: all" is needed so when we click on the admin panel, we don't gain focus on the noa canvas
        <div className="h-full select-none" style={{ pointerEvents: "all" }}>
          <Background
            onClick={() => {
              setSelectedTab(InventoryTab.NONE);
              noa.container.setPointerLock(true);
            }}
            style={{
              backgroundColor: selectedTab === InventoryTab.NONE ? "transparent" : "rgba(0,0,0,0.2)",
            }}
          />
          <div
            className="flex flex-row float-left relative z-50 h-[80%] mt-[5%] pr-7 pt-7"
            style={{
              backgroundColor: selectedTab === InventoryTab.NONE ? "transparent" : `${SIDEBAR_BACKGROUND_COLOR}`,
            }}
          >
            <TabRadioSelector layers={layers} selectedTab={selectedTab} setSelectedTab={setSelectedTab} />
            <div className={`bg-[${SIDEBAR_BACKGROUND_COLOR}]`}>{SelectedTab}</div>
          </div>
        </div>
      );
    },
  });
}

const InventoryContainer = styled.div`
  width: 100%;
  background-color: lightgray;
  display: grid;
  grid-template-columns: repeat(2, auto);
  justify-content: center;
  align-items: center;
  grid-gap: 10px;
  padding: 20px;
  z-index: 11;
  pointer-events: all;
`;
