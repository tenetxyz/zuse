import { useEffect, useState } from "react";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { useComponentValue } from "@latticexyz/react";
import { VoxelTypeStore, VoxelTypeStoreFilters } from "./VoxelTypeStore";
import RegisterCreation, { RegisterCreationFormData } from "./RegisterCreation";
import { InventoryTab, TabRadioSelector } from "./TabRadioSelector";
import CreationStore, { CreationStoreFilters } from "./CreationStore";
import { Absolute, AbsoluteBorder, Background, Center } from ".";
import styled from "styled-components";
import ClassifierStore from "./ClassifierStore";
import { ElectiveBar } from "./ElectiveBar";
import { getComponentValue, setComponent } from "@latticexyz/recs";
import { onStreamUpdate } from "../../../utils/stream";
import { UiComponentType } from "../../noa/createNoaLayer";
import { FocusedUiType } from "../../noa/components/FocusedUi";

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
          components: { UI, FocusedUi },
          SingletonEntity,
          noa,
          api: { disableOrEnableInputs, toggleInventory },
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

      useEffect(() => {
        const isInventoryOpen = getComponentValue(UI, SingletonEntity)?.showInventory;
        const isUiOpen = selectedTab !== InventoryTab.NONE || isInventoryOpen;

        disableOrEnableInputs(isUiOpen);

        if (selectedTab !== InventoryTab.NONE) {
          setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.SIDEBAR });

          // TODO: if we have multiple focused UI components, we should considerhaving a component that tracks
          // the currently focused ui component. Then,when a new ui component is focused, we close the other ones
          toggleInventory(false, undefined, false);
        }
      }, [selectedTab]);

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
