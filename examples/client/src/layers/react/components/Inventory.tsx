import React from "react";
import { defineQuery, Entity, getComponentValue, Has, HasValue, UpdateType } from "@latticexyz/recs";
import { to64CharAddress } from "../../../utils/entity";
import { concat, map, of, scan } from "rxjs";
import { Absolute, AbsoluteBorder, Background, Center, Crafting } from "./common";
import { range } from "@latticexyz/utils";
import { VoxelTypeStore } from "./VoxelTypeStore";
import { ActionBarWrapper, INVENTORY_HEIGHT, INVENTORY_WIDTH } from "./InventoryHud";
import { Layers } from "../../../types";

interface Props {
  layers: Layers;
  craftingSideLength: number;
  holdingVoxelType: Entity | undefined;
  setHoldingVoxelType: (voxelType: Entity | undefined) => void;
  Slots: JSX.Element[];
}
export const Inventory: React.FC<Props> = ({
  layers,
  craftingSideLength,
  holdingVoxelType,
  setHoldingVoxelType,
  Slots,
}) => {
  return (
    <>
      <div>
        {/* <Crafting
          layers={layers}
          holdingVoxelType={holdingVoxelType}
          sideLength={craftingSideLength}
          setHoldingVoxelType={setHoldingVoxelType}
        /> */}
        <ActionBarWrapper>
          {[...range(INVENTORY_WIDTH * (INVENTORY_HEIGHT - 1))].map((i) => i + INVENTORY_WIDTH).map((i) => Slots[i])}
        </ActionBarWrapper>
      </div>
    </>
  );
};