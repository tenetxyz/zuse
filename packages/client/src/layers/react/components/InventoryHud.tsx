// the name of this file is misleading
// it also contains UI elements that are NOT related to the inventory, namely, the music control (bottom left corner)
// and the opcraft logo (bottom right corner)
import React, { useEffect, useState } from "react";
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
import { to64CharAddress } from "../../../utils/entity";
import { Sounds } from "./Sounds";
import { CreativeInventory } from "./CreativeInventory";
import { Inventory } from "./Inventory";
import { InventoryTab, TabRadioSelector } from "./TabRadioSelector";
import RegisterCreation, { RegisterCreationFormData } from "./RegisterCreation";
import { Layers } from "../../../types";
import CreationStore, { CreationStoreFilters } from "./CreationStore";
import { entityToVoxelType, voxelTypeToEntity, voxelTypeDataKeyToVoxelVariantDataKey } from "../../noa/types";

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
          getVoxelIconUrl,
        },
        noa: {
          components: { UI, InventoryIndex, SelectedSlot, CraftingTable },
        },
      } = layers;

      const VoxelsIOwnQuery = defineQuery(
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
        VoxelsIOwnQuery.update$.pipe(
          scan((acc, curr) => {
            const voxelType = getComponentValue(VoxelType, curr.entity);
            if (!voxelType) return { ...acc };
            const voxelTypeString = voxelTypeToEntity(voxelType);
            acc[voxelTypeString] = acc[voxelTypeString] ?? 0;
            if (curr.type === UpdateType.Exit) {
              return { ...acc };
            }

            acc[voxelTypeString]++;
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
        connectedClients$,
        inventoryIndex$,
        craftingTable$,
      ]).pipe(map((props) => ({ props })));
    },
    ({ props }) => {
      const [
        numVoxelsIOwnOfType,
        { layers, show, craftingSideLength },
        selectedSlot,
        connectedClients,
      ] = props;
      const {
        network: {
          api: { removeVoxels },
          contractComponents: { OwnedBy, VoxelType },
          network: { connectedAddress },
          getVoxelIconUrl,
        },
        noa: {
          api: { playRandomTheme, playNextTheme, toggleInventory },
          components: { InventoryIndex },
        },
      } = layers;

      const [holdingVoxelType, setHoldingVoxelType] = useState<
        Entity | undefined
      >();
      const [selectedTab, setSelectedTab] = React.useState<InventoryTab>(
        InventoryTab.INVENTORY
      );

      useEffect(() => {
        if (!show) setHoldingVoxelType(undefined);
      }, [show]);

      useEffect(() => {
        if (!holdingVoxelType) {
          document.body.style.cursor = "unset";
          return;
        }
        const voxelTypeKey = entityToVoxelType(holdingVoxelType);
        const voxelVariantTypeKey = voxelTypeDataKeyToVoxelVariantDataKey(voxelTypeKey);
        const icon = getVoxelIconUrl(voxelVariantTypeKey);
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

        // since holdingVoxelTypeSlot can be 0, we cannot use !holdingVoxelTypeSlot
        if (holdingVoxelTypeSlot === undefined) {
          console.warn(
            "we are not holding a voxel of type",
            holdingVoxelType
          );
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
        numVoxelsIOwnOfType[voxelTypeIdAtSlot] = 0;

        const ownedEntitiesOfType = [
          ...runQuery([
            HasValue(OwnedBy, {
              value: to64CharAddress(connectedAddress.get()),
            }),
            HasValue(VoxelType, { value: voxelTypeIdAtSlot }),
          ]),
        ];

        // since we no longer have VoxelTypes of this type, remove this from the InventoryIndex,
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
            getVoxelIconUrl={getVoxelIconUrl}
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
        </BottomBar>
      );

      // This state is hoisted up to this component so that the state is not lost when leaving the inventory to select voxels
      const [registerCreationFormData, setRegisterCreationFormData] =
        useState<RegisterCreationFormData>({
          name: "",
          description: "",
        });
      const [creationStoreFilters, setCreationStoreFilters] =
        useState<CreationStoreFilters>({
          search: "",
          isMyCreation: false,
        });

      const getPageForSelectedTab = () => {
        switch (selectedTab) {
          case InventoryTab.INVENTORY:
            return (
              <Inventory
                layers={layers}
                craftingSideLength={craftingSideLength}
                holdingVoxelType={holdingVoxelType}
                setHoldingVoxelType={setHoldingVoxelType}
                Slots={Slots}
              />
            );
          case InventoryTab.CREATIVE:
            return <CreativeInventory layers={layers} />;
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
              <CreationStore
                layers={layers}
                filters={creationStoreFilters}
                setFilters={setCreationStoreFilters}
              />
            );
        }
      };
      const SelectedTab = getPageForSelectedTab();

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
                <TabRadioSelector
                  selectedTab={selectedTab}
                  setSelectedTab={setSelectedTab}
                />
                {SelectedTab}
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
