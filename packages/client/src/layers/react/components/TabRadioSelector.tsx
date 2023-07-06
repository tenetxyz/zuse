// this component is used by the inventoryHud to help users select which inventory pane they're looking at
import React from "react";
import { SIDEBAR_BACKGROUND_COLOR } from "../TenetSidebar";
import { Layers } from "../../../types";

export enum InventoryTab {
  VOXEL_TYPE_STORE = "All Voxels",
  REGISTER_CREATION = "Register Creation",
  CREATION_STORE = "Creations",
  CLASSIFIER_STORE = "Classify Your Creations",
  NONE = "None",
}

interface Props {
  layers: Layers;
  selectedTab: InventoryTab;
  setSelectedTab: React.Dispatch<React.SetStateAction<InventoryTab>>;
}

export const TabRadioSelector: React.FC<Props> = ({ layers, selectedTab, setSelectedTab }) => {
  const {
    noa: {
      api: { disableOrEnableInputs },
    },
  } = layers;
  React.useEffect(() => {
    disableOrEnableInputs(selectedTab !== InventoryTab.NONE);
  }, []);

  return (
    <div
      className="p-2 text-xl"
      style={{
        backgroundColor: selectedTab === InventoryTab.NONE ? "transparent" : `${SIDEBAR_BACKGROUND_COLOR}`,
      }}
    >
      {Object.values(InventoryTab)
        .filter((tabName) => tabName !== InventoryTab.NONE)
        .map((tabName, idx) => {
          return (
            <div
              key={`inventory-tab-${idx}`}
              onClick={() => {
                setSelectedTab(tabName);
              }}
              className="p-5 cursor-pointer"
            >
              <p
                style={{
                  color: selectedTab === tabName ? "#25c6cc" : "white",
                }}
              >
                {tabName}
              </p>
            </div>
          );
        })}
    </div>
  );
};
