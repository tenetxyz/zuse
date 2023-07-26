import React, { useEffect } from "react";
import { SingletonID } from "@latticexyz/network";
import { Entity, getComponentValue, runQuery, HasValue } from "@latticexyz/recs";
import { range } from "@latticexyz/utils";
import styled from "styled-components";
import { Layers } from "../../../../types";
import { Slot } from "./Slot";
import { to64CharAddress } from "../../../../utils/entity";

export const Crafting: React.FC<{
  layers: Layers;
  holdingVoxelType: Entity | undefined;
  setHoldingVoxelType: (voxelType: Entity | undefined) => void;
  sideLength: number;
}> = ({ layers, holdingVoxelType, setHoldingVoxelType, sideLength }) => {
  const {
    network: {
      contractComponents: { OwnedBy, VoxelType },
      network: { connectedAddress },
      api: { craft },
      getVoxelIconUrl,
    },
    noa: {
      api: { getCraftingTable, setCraftingTableIndex, clearCraftingTable, getCraftingResult, getTrimmedCraftingTable },
      world,
    },
  } = layers;

  function getOverrideId(i: number) {
    return ("crafting" + i) as Entity;
  }

  useEffect(() => {
    return () => {
      for (let i = 0; i < sideLength * sideLength; i++) {
        OwnedBy.removeOverride(getOverrideId(i));
        clearCraftingTable();
      }
    };
  }, []);

  const craftingTable = getCraftingTable();
  const craftingResult = getCraftingResult();

  function getX(i: number) {
    return Math.floor(i / sideLength);
  }

  function getY(i: number) {
    return i % sideLength;
  }

  function handleInput(i: number) {
    const x = getX(i);
    const y = getY(i);

    const voxelAtIndex = craftingTable[x][y];
    const voxelTypeAtIndex = getComponentValue(VoxelType, voxelAtIndex)?.value as Entity | undefined;

    // If we are not holding a voxel but there is a voxel at this position, grab the voxel
    if (!holdingVoxelType) {
      OwnedBy.removeOverride(getOverrideId(i));
      setCraftingTableIndex([x, y], undefined);
      setHoldingVoxelType(voxelTypeAtIndex);
      return;
    }

    // If there already is a voxel of the current type at this position, remove the voxel
    if (voxelTypeAtIndex === holdingVoxelType) {
      OwnedBy.removeOverride(getOverrideId(i));
      setCraftingTableIndex([x, y], undefined);
      return;
    }

    // Check if we still own an entity of the held voxel type
    const ownedEntitiesOfType = [
      ...runQuery([
        HasValue(OwnedBy, {
          player: connectedAddress.get(),
        }),
        HasValue(VoxelType, { voxelTypeId: holdingVoxelType }),
      ]),
    ];

    // If we don't own a voxel of the held voxel type, ignore this click
    if (ownedEntitiesOfType.length === 0) {
      console.warn("no owned entities of type", holdingVoxelType);
      return;
    }

    // Set the optimisitic override for this crafting slot
    const ownedEntityOfType = ownedEntitiesOfType[0];
    OwnedBy.removeOverride(getOverrideId(i));
    OwnedBy.addOverride(getOverrideId(i), {
      entity: ownedEntityOfType,
      value: { value: SingletonID },
    });

    // Place the held voxel on the crafting table
    setCraftingTableIndex([x, y], ownedEntityOfType);

    // If this was the last voxel of this type we own, reset the cursor
    if (ownedEntitiesOfType.length === 1) {
      setHoldingVoxelType(undefined);
    }
  }

  async function handleOutput() {
    if (!craftingResult) return;
    const { voxels } = getTrimmedCraftingTable();
    clearCraftingTable();
    await craft(voxels, craftingResult);
  }

  const Slots = [...range(sideLength * sideLength)].map((index) => {
    const x = getX(index);
    const y = getY(index);
    const voxelIndex = craftingTable[x][y];
    const voxelType = getComponentValue(VoxelType, voxelIndex)?.value as Entity | undefined;
    return (
      <Slot
        key={"crafting-slot" + index}
        voxelType={voxelType}
        onClick={() => handleInput(index)}
        getVoxelIconUrl={getVoxelIconUrl}
      />
    );
  });

  return (
    <CraftingWrapper>
      <CraftingInput sideLength={sideLength}>{[...range(sideLength * sideLength)].map((i) => Slots[i])}</CraftingInput>
      <CraftingOutput>
        <Slot
          voxelType={getCraftingResult()}
          onClick={() => handleOutput()}
          selected={true}
          getVoxelIconUrl={getVoxelIconUrl}
        />
      </CraftingOutput>
    </CraftingWrapper>
  );
};

const CraftingWrapper = styled.div`
  width: 100%;
  background-color: lightgray;
  display: grid;
  grid-template-columns: repeat(2, auto);
  justify-content: center;
  align-items: center;
  grid-gap: 100px;
  padding: 20px;
  z-index: 11;
  pointer-events: all;
`;

const CraftingInput = styled.div<{ sideLength: number }>`
  background-color: rgb(0 0 0 / 40%);
  display: grid;
  grid-template-columns: repeat(${(p) => p.sideLength}, auto);
  align-items: start;
  justify-content: start;
  pointer-events: all;
  border: 5px lightgray solid;
  z-index: 10;
`;

const CraftingOutput = styled.div``;
