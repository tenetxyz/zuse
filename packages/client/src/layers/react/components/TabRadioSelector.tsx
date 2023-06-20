// this component is used by the inventoryHud to help users select which inventory pane they're looking at
import React from "react";

export enum InventoryTab {
  INVENTORY = "Inventory",
  CREATIVE = "All Voxels",
  REGISTER_CREATION = "Register Creation",
  CREATION_STORE = "Creations",
}

interface Props {
  selectedTab: InventoryTab;
  setSelectedTab: React.Dispatch<React.SetStateAction<InventoryTab>>;
}

export const TabRadioSelector: React.FC<Props> = ({
  selectedTab,
  setSelectedTab,
}) => {
  return (
    <div className="bg-[#888888] p-2 cursor-pointer border-4 border-solid border-gray-400 text-xl">
      {Object.values(InventoryTab).map((tabName, idx) => {
        return (
          <div
            key={`inventory-tab-${idx}`}
            onClick={() => {
              setSelectedTab(tabName);
            }}
            className="p-5"
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
