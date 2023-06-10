// the name of this file is misleading
// it also contains UI elements that are NOT related to the inventory, namely, the music control (bottom left corner)
// and the opcraft logo (bottom right corner)
import React, { useEffect, useMemo, useState } from "react";
import { registerUIComponent } from "../engine";
import { combineLatest, concat, map, of, scan } from "rxjs";
import styled from "styled-components";
import { Absolute, AbsoluteBorder, Background, Center, Slot } from "./common";
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
import { getVoxelIconUrl } from "../../noa/constants";
import { VoxelTypeIdToKey } from "../../network/constants";
import { formatEntityID, to64CharAddress } from "../../../utils/entity";
import { Sounds } from "./Sounds";
import { CreativeInventory } from "./CreativeInventory";
import { Inventory } from "./Inventory";
import { UrgentNotification } from "./UrgentNotification";

// This gives us 36 inventory slots. As of now there are 34 types of voxeltypes, so it should fit.
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
    (layers) => {
      const {
        network: {
          contractComponents: { OwnedBy, VoxelType },
          streams: { connectedClients$, balanceGwei$ },
          network: { connectedAddress },
        },
        noa: {
          components: { UI, InventoryIndex, SelectedSlot, CraftingTable },
          streams: { stakeAndClaim$ },
        },
      } = layers;

      const numVoxelsIOwnOfTypeQuery = defineQuery(
        [
          HasValue(OwnedBy, { value: to64CharAddress(connectedAddress.get()) }),
          Has(VoxelType),
        ],
        {
          runOnInit: true,
        }
      );

      // maps voxel type -> number of voxels I own of that type
      const numVoxelsIOwnOfType$ = concat<{ [key: string]: number }[]>(
        of({}),
        numVoxelsIOwnOfTypeQuery.update$.pipe(
          scan((acc, curr) => {
            const voxelType = getComponentValue(VoxelType, curr.entity)?.value;
            if (!voxelType) return { ...acc };
            acc[voxelType] = acc[voxelType] ?? 0;
            if (curr.type === UpdateType.Exit) {
              acc[voxelType]--; // why do we decrement here? we don't increment before this line
              return { ...acc };
            }

            acc[voxelType]++;
            return { ...acc };
          }, {} as { [key: string]: number })
        )
      );

      const showInventory$ = concat(
        of({ layers, show: false, craftingSideLength: 2 }),
        UI.update$.pipe(
          map((e) => ({
            layers,
            show: e.value[0]?.showInventory,
            craftingSideLength: e.value[0]?.showCrafting ? 3 : 2, // Increase crafting side length if crafting flag is set
          }))
        )
      );

      const inventoryIndex$ = concat(
        of(0),
        InventoryIndex.update$.pipe(map((e) => e.entity))
      );
      const selectedSlot$ = concat(
        of(0),
        SelectedSlot.update$.pipe(map((e) => e.value[0]?.value))
      );
      const craftingTable$ = concat(of(0), CraftingTable.update$);

      return combineLatest([
        numVoxelsIOwnOfType$,
        showInventory$,
        selectedSlot$,
        stakeAndClaim$,
        connectedClients$,
        balanceGwei$,
        inventoryIndex$,
        craftingTable$,
      ]).pipe(map((props) => ({ props })));
    },
    ({ props }) => {
      const [
        numVoxelsIOwnOfType,
        { layers, show, craftingSideLength },
        selectedSlot,
        stakeAndClaim,
        connectedClients,
        balance,
      ] = props;
      const {
        network: {
          api: { removeVoxels },
          contractComponents: { OwnedBy, VoxelType },
          network: { connectedAddress },
        },
        noa: {
          api: { playRandomTheme, playNextTheme, toggleInventory },
          components: { InventoryIndex },
        },
      } = layers;

      const [holdingVoxelType, setHoldingVoxelType] = useState<
        Entity | undefined
      >();
      const [isUsingPersonalInventory, setIsUsingPersonalInventory] =
        useState<boolean>(true);

      const { claim } = stakeAndClaim;

      useEffect(() => {
        if (!show) setHoldingVoxelType(undefined);
      }, [show]);

      useEffect(() => {
        if (!holdingVoxelType) {
          document.body.style.cursor = "unset";
          return;
        }
        const voxelTypeKey = VoxelTypeIdToKey[holdingVoxelType as Entity];
        const icon = getVoxelIconUrl(voxelTypeKey);
        document.body.style.cursor = `url(${icon}) 12 12, auto`;
      }, [holdingVoxelType]);

      function moveVoxelType(slot: number) {
        console.log("moveVoxelType", slot);
        const voxelTypeAtSlot = [
          ...getEntitiesWithValue(InventoryIndex, { value: slot }),
        ][0];

        // If not currently holding a voxel, grab the voxel at this slot
        if (!holdingVoxelType) {
          const numVoxelsOfTypeIOwn =
            voxelTypeAtSlot && numVoxelsIOwnOfType[voxelTypeAtSlot];
          if (numVoxelsOfTypeIOwn > 0) {
            setHoldingVoxelType(voxelTypeAtSlot);
          }
          return;
        }

        // Else (if currently holding a voxel), swap the holding voxel with the voxel at this position
        const holdingVoxelTypeSlot = getComponentValue(
          InventoryIndex,
          holdingVoxelType
        )?.value;
        if (!holdingVoxelTypeSlot) {
          console.warn("holding voxel has no slot", holdingVoxelType);
          return;
        }
        setComponent(InventoryIndex, holdingVoxelType, { value: slot });
        voxelTypeAtSlot &&
          setComponent(InventoryIndex, voxelTypeAtSlot, {
            value: holdingVoxelTypeSlot,
          });
        setHoldingVoxelType(undefined);
      }

      function removeVoxelType(slot: number) {
        const voxelTypeIdAtSlot = [
          ...getEntitiesWithValue(InventoryIndex, { value: slot }),
        ][0];
        if (!voxelTypeIdAtSlot) {
          return;
        }

        const ownedEntitiesOfType = [
          ...runQuery([
            HasValue(OwnedBy, {
              value: to64CharAddress(connectedAddress.get()),
            }),
            HasValue(VoxelType, { value: voxelTypeIdAtSlot }),
          ]),
        ];

        // since we no longer have voxeltypes of this type, remove this from the InventoryIndex,
        // so new voxeltypes can be placed on that index
        removeComponent(InventoryIndex, voxelTypeIdAtSlot);

        // remove the voxels at this slot
        removeVoxels(ownedEntitiesOfType);
      }

      // Map each inventory slot to the corresponding voxel type at this slot index
      const Slots = [...range(INVENTORY_HEIGHT * INVENTORY_WIDTH)].map((i) => {
        const voxelType = [
          ...getEntitiesWithValue(InventoryIndex, { value: i }),
        ][0];
        // console.log("getting slots");
        // console.log(InventoryIndex);
        const quantity = voxelType && numVoxelsIOwnOfType[voxelType];
        return (
          <Slot
            key={"slot" + i}
            voxelType={quantity ? voxelType : undefined}
            quantity={quantity || undefined}
            onClick={() => moveVoxelType(i)}
            onRightClick={() => removeVoxelType(i)}
            disabled={voxelType === holdingVoxelType}
            selected={i === selectedSlot}
          />
        );
      });

      const Bottom = (
        <BottomBar>
          <ConnectedPlayersContainer>
            <PlayerCount>{connectedClients}</PlayerCount>
            <PixelatedImage src="/img/mud-player.png" width={35} />
            <Sounds
              playRandomTheme={playRandomTheme}
              playNextTheme={playNextTheme}
            />
          </ConnectedPlayersContainer>
          <ActionBarWrapper>
            {[...range(INVENTORY_WIDTH)].map((i) => Slots[i])}
          </ActionBarWrapper>
          <LogoContainer>
            <PixelatedImage src="/img/opcraft-dark.png" width={150} />
          </LogoContainer>
          <UrgentNotification claim={claim} balance={balance} />
        </BottomBar>
      );
      const SelectedInventory = isUsingPersonalInventory ? (
        <Inventory
          layers={layers}
          craftingSideLength={craftingSideLength}
          holdingVoxelType={holdingVoxelType}
          setHoldingVoxelType={setHoldingVoxelType}
          Slots={Slots}
        />
      ) : (
        <CreativeInventory layers={layers} />
      );

      const InventoryWrapper = (
        <Absolute>
          <Center>
            <Background
              onClick={() => {
                toggleInventory(false);
              }}
            />
            <AbsoluteBorder borderColor={"#999999"} borderWidth={3}>
              <InventoryContainer>
                <InventoryModeToggle
                  // className="text-red text-2xl h-10 cursor-pointer border-2 border-white rounded-md flex justify-center items-center"
                  onClick={() =>
                    setIsUsingPersonalInventory(!isUsingPersonalInventory)
                  }
                >
                  {isUsingPersonalInventory ? "to creative" : "to personal"}
                </InventoryModeToggle>
                {SelectedInventory}
              </InventoryContainer>
            </AbsoluteBorder>
          </Center>
        </Absolute>
      );

      return (
        <Wrapper>
          <>
            {show ? InventoryWrapper : null}
            {Bottom}
          </>
        </Wrapper>
      );
    }
  );
}

const InventoryModeToggle = styled.div`
  background-color: #888888;
  padding: 20px;
  border: 4px solid #999999;
  cursor: pointer;
`;

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
