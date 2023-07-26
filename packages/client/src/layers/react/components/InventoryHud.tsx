// the name of this file is misleading
// it also contains UI elements that are NOT related to the inventory, namely, the music control (bottom left corner)
// and the opcraft logo (bottom right corner)
import React, { useEffect, useState } from "react";
import { registerUIComponent } from "../engine";
import { combineLatest, concat, map, of, scan } from "rxjs";
import styled from "styled-components";
import { Absolute, AbsoluteBorder, Center, Slot } from "./common";
import { range } from "@latticexyz/utils";
import {
  defineQuery,
  Entity,
  getComponentValue,
  getEntitiesWithValue,
  Has,
  HasValue,
  removeComponent,
  runQuery,
  setComponent,
  UpdateType,
} from "@latticexyz/recs";
import { to64CharAddress } from "../../../utils/entity";
import { Inventory } from "./Inventory";
import { Layers } from "../../../types";
import { entityToVoxelType } from "../../noa/types";
import { firstFreeInventoryIndex } from "../../noa/systems/createInventoryIndexSystem";
import { StatusHud } from "./StatusHud";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { useComponentUpdate } from "../../../utils/useComponentUpdate";
import { useComponentValue } from "@latticexyz/react";
import { getWorldScale } from "../../../utils/coord";

// This gives us 36 inventory slots. As of now there are 34 types of VoxelTypes, so it should fit.
export const INVENTORY_WIDTH = 9;
export const INVENTORY_HEIGHT = 4;

export function registerInventoryHud() {
  registerUIComponent(
    "Inventory",
    {
      rowStart: 1,
      rowEnd: 13,
      colStart: 1,
      colEnd: 13,
    },
    (layers: Layers) => {
      const {
        network: {
          contractComponents: { OwnedBy, VoxelType },
          streams: { connectedClients$ },
          network: { connectedAddress },
        },
        noa: {
          components: { UI, InventoryIndex, SelectedSlot, CraftingTable },
          noa,
        },
      } = layers;

      const VoxelsIOwnQuery = defineQuery([HasValue(OwnedBy, { player: connectedAddress.get() })], {
        runOnInit: true,
      });

      // maps voxel type -> number of voxels I own of that type
      const numVoxelsIOwnOfType$ = concat<{ [key: string]: number }[]>(
        of({}),
        VoxelsIOwnQuery.update$.pipe(
          scan((acc, curr) => {
            const voxelType = getComponentValue(VoxelType, curr.entity);
            if (!voxelType) return { ...acc };
            const voxelBaseTypeId = voxelType.voxelTypeId;
            acc[voxelBaseTypeId] = acc[voxelBaseTypeId] ?? 0;
            if (curr.type === UpdateType.Exit) {
              return { ...acc };
            }

            acc[voxelBaseTypeId]++;
            return { ...acc };
          }, {} as { [key: string]: number })
        )
      );

      const showInventory$ = concat(
        of({ layers, show: false, craftingSideLength: 2 }),
        UI.update$.pipe(
          map((e) => ({
            layers,
            craftingSideLength: e.value[0]?.showCrafting ? 3 : 2, // Increase crafting side length if crafting flag is set
          }))
        )
      );

      const inventoryIndex$ = concat(of(0), InventoryIndex.update$.pipe(map((e) => e.entity)));
      const selectedSlot$ = concat(of(0), SelectedSlot.update$.pipe(map((e) => e.value[0]?.value)));
      const craftingTable$ = concat(of(0), CraftingTable.update$);

      return combineLatest([
        numVoxelsIOwnOfType$,
        showInventory$,
        selectedSlot$,
        connectedClients$,
        inventoryIndex$,
        craftingTable$,
      ]).pipe(map((props) => ({ props })));
    },
    ({ props }) => {
      const [numVoxelsIOwnOfType, { layers, craftingSideLength }, selectedSlot, connectedClients] = props;
      const {
        network: {
          api: { removeVoxels },
          contractComponents: { OwnedBy, VoxelType },
          network: { connectedAddress },
          getVoxelIconUrl,
          getVoxelTypePreviewUrl,
        },
        noa: {
          components: { InventoryIndex, FocusedUi },
          SingletonEntity,
        },
      } = layers;

      const [holdingVoxelType, setHoldingVoxelType] = useState<Entity | undefined>();

      useEffect(() => {
        if (!holdingVoxelType) {
          document.body.style.cursor = "unset";
          return;
        }
        const voxelTypeKey = entityToVoxelType(holdingVoxelType);
        const icon = getVoxelIconUrl(voxelTypeKey.voxelVariantTypeId);
        document.body.style.cursor = `url(${icon}) 12 12, auto`;
      }, [holdingVoxelType]);

      const onSlotClick = (slotIdx: number, event: React.MouseEvent<HTMLDivElement>) => {
        if (event.shiftKey) {
          transferItemToHotbarOrInventory(slotIdx);
        } else {
          moveVoxelType(slotIdx);
        }
      };

      const INVALID_SLOT_IDX = -1;
      const getNewItemIndex = (slotIdx: number): number => {
        if (slotIdx < 9) {
          // transfer it to the first slot in your inventory
          const freeInventoryIndex = firstFreeInventoryIndex(InventoryIndex, 9);
          if (freeInventoryIndex > INVENTORY_WIDTH * INVENTORY_HEIGHT) {
            return INVALID_SLOT_IDX;
          }
          return freeInventoryIndex;
        } else {
          // transfer it to the first slot in your hotbar
          const freeInventoryIndex = firstFreeInventoryIndex(InventoryIndex, 0);
          if (freeInventoryIndex >= 9) {
            return INVALID_SLOT_IDX;
          }
          return freeInventoryIndex;
        }
      };

      const transferItemToHotbarOrInventory = (slotIdx: number) => {
        let newItemIndex = getNewItemIndex(slotIdx);
        if (newItemIndex === INVALID_SLOT_IDX) {
          return; // do nothing. They don't have any more slots
        }
        const voxelTypeAtSlot = [...getEntitiesWithValue(InventoryIndex, { value: slotIdx })][0];
        setComponent(InventoryIndex, voxelTypeAtSlot, { value: newItemIndex });
      };

      const moveVoxelType = (slot: number) => {
        const voxelTypeAtSlot = [...getEntitiesWithValue(InventoryIndex, { value: slot })][0];

        // If not currently holding a voxel, grab the voxel at this slot
        if (!holdingVoxelType) {
          const numVoxelsOfTypeIOwn = voxelTypeAtSlot && numVoxelsIOwnOfType[voxelTypeAtSlot];
          if (numVoxelsOfTypeIOwn > 0) {
            setHoldingVoxelType(voxelTypeAtSlot);
          }
          return;
        }

        // Else (if currently holding a voxel), swap the holding voxel with the voxel at this position
        const holdingVoxelTypeSlot = getComponentValue(InventoryIndex, holdingVoxelType)?.value;

        // since holdingVoxelTypeSlot can be 0, we cannot use !holdingVoxelTypeSlot
        if (holdingVoxelTypeSlot === undefined) {
          console.warn("we are not holding a voxel of type", holdingVoxelType);
          return;
        }
        setComponent(InventoryIndex, holdingVoxelType, { value: slot });
        voxelTypeAtSlot &&
          setComponent(InventoryIndex, voxelTypeAtSlot, {
            value: holdingVoxelTypeSlot,
          });
        setHoldingVoxelType(undefined);
      };

      function removeVoxelType(slot: number) {
        const voxelBaseTypeIdAtSlot = [...getEntitiesWithValue(InventoryIndex, { value: slot })][0];
        if (!voxelBaseTypeIdAtSlot) {
          return;
        }
        numVoxelsIOwnOfType[voxelBaseTypeIdAtSlot] = 0;

        const ownedEntitiesOfType = [
          ...runQuery([
            HasValue(OwnedBy, {
              player: connectedAddress.get(),
            }),
            HasValue(VoxelType, { voxelTypeId: voxelBaseTypeIdAtSlot }), // TODO: is it ok to just look for one value in this column?
          ]),
        ];

        // since we no longer have VoxelTypes of this type, remove this from the InventoryIndex,
        // so new voxeltypes can be placed on that index
        removeComponent(InventoryIndex, voxelBaseTypeIdAtSlot);

        // remove the voxels at this slot
        removeVoxels(ownedEntitiesOfType);
      }

      const focusedUiType = useComponentValue(FocusedUi, SingletonEntity);
      const isInventoryFocused = focusedUiType?.value === FocusedUiType.INVENTORY;
      useEffect(() => {
        if (!isInventoryFocused) {
          setHoldingVoxelType(undefined);
        }
      }, [isInventoryFocused]);

      // Map each inventory slot to the corresponding voxel type at this slot index
      const Slots = [...range(INVENTORY_HEIGHT * INVENTORY_WIDTH)].map((i) => {
        const voxelTypeId = [...getEntitiesWithValue(InventoryIndex, { value: i })][0];
        const quantity = voxelTypeId && numVoxelsIOwnOfType[voxelTypeId];
        const voxelTypePreview = (voxelTypeId && getVoxelTypePreviewUrl(voxelTypeId)) || "";
        return (
          <Slot
            key={"slot" + i}
            voxelType={quantity ? voxelTypeId : undefined}
            quantity={quantity || undefined}
            iconUrl={voxelTypePreview}
            onClick={(event: any) => onSlotClick(i, event)}
            onRightClick={() => removeVoxelType(i)}
            disabled={voxelTypeId === holdingVoxelType}
            selected={i === selectedSlot}
          />
        );
      });

      const Bottom = (
        <BottomBar>
          <ConnectedPlayersContainer>
            {/* <PlayerCount>{connectedClients}</PlayerCount>
            <PixelatedImage src="/img/mud-player.png" width={35} />
            <Sounds playRandomTheme={playRandomTheme} playNextTheme={playNextTheme} /> */}
          </ConnectedPlayersContainer>
          <div className="flex flex-col">
            {/* <StatusHud layers={layers} /> */}
            <ActionBarWrapper>{[...range(INVENTORY_WIDTH)].map((i) => Slots[i])}</ActionBarWrapper>
          </div>
        </BottomBar>
      );

      const InventoryWrapper = (
        <Absolute>
          <Center>
            <AbsoluteBorder borderColor={"#999999"} borderWidth={3}>
              <InventoryContainer>
                <Inventory
                  layers={layers}
                  craftingSideLength={craftingSideLength}
                  holdingVoxelType={holdingVoxelType}
                  setHoldingVoxelType={setHoldingVoxelType}
                  Slots={Slots}
                />
              </InventoryContainer>
            </AbsoluteBorder>
          </Center>
        </Absolute>
      );

      return (
        <Wrapper>
          <>
            {isInventoryFocused ? InventoryWrapper : null}
            {Bottom}
          </>
        </Wrapper>
      );
    }
  );
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

const PixelatedImage = styled.img`
  image-rendering: pixelated;
`;

const PlayerCount = styled.span`
  font-size: 1.5em;
`;

const ConnectedPlayersContainer = styled.div`
  display: grid;
  justify-content: start;
  padding: 0 20px;
  grid-auto-flow: column;
  align-items: center;
`;

const LogoContainer = styled.div`
  display: grid;
  justify-items: end;
  padding: 0 20px;
`;

export const ActionBarWrapper = styled.div`
  background-color: rgb(0 0 0 / 40%);
  display: grid;
  grid-template-columns: repeat(9, 1fr);
  align-items: center;
  pointer-events: all;
  border: 5px lightgray solid;
  z-index: 10;
  position: relative;
`;

const BottomBar = styled.div`
  display: grid;
  align-items: end;
  justify-content: space-between;
  grid-template-columns: 1fr auto 1fr;
  width: 100%;
  padding-bottom: 20px;
  position: relative;
`;

const Wrapper = styled(Center)`
  display: grid;
  align-items: end;
`;
