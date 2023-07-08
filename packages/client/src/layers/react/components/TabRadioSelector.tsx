// this component is used by the inventoryHud to help users select which inventory pane they're looking at
import React from "react";
import { Layers } from "../../../types";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { setComponent } from "@latticexyz/recs";
import { useComponentValue } from "@latticexyz/react";

const sidebarTabTypeNames = {
  [FocusedUiType.SIDEBAR_VOXEL_TYPE_STORE]: "All Voxels",
  [FocusedUiType.SIDEBAR_CREATION_STORE]: "Creations",
  [FocusedUiType.SIDEBAR_REGISTER_CREATION]: "Register Creation",
  [FocusedUiType.SIDEBAR_CLASSIFY_STORE]: "Classify Creations",
};

interface Props {
  layers: Layers;
}

export const TabRadioSelector: React.FC<Props> = ({ layers }: Props) => {
  const {
    noa: {
      components: { FocusedUi },
      SingletonEntity,
    },
  } = layers;

  const focusedUi = useComponentValue(FocusedUi, SingletonEntity);
  return (
    <div className="p-2 text-xl">
      {Object.entries(sidebarTabTypeNames).map(([tabType, tabName], idx) => {
        return (
          <div
            key={`inventory-tab-${idx}`}
            onClick={() => {
              setComponent(FocusedUi, SingletonEntity, { value: tabType });
            }}
            className="p-5 cursor-pointer"
          >
            <p
              style={{
                color: focusedUi?.value === tabType ? "#25c6cc" : "white",
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
