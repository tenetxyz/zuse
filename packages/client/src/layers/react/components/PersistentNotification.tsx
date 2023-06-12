import {
  Absolute,
  AbsoluteBorder,
  Background,
  Center,
  Container,
  Gold,
  Red,
  Slot,
} from "./common";
import React, { useEffect, useState } from "react";
import styled from "styled-components";
import {
  ComponentValue,
  Entity,
  getComponentValue,
  getEntitiesWithValue,
  HasValue,
  removeComponent,
  runQuery,
  setComponent,
  Type,
} from "@latticexyz/recs";
import { registerUIComponent } from "../engine";
import { VoxelTypeIdToKey } from "../../network/constants";
import { getVoxelIconUrl } from "../../noa/constants";
import { to64CharAddress } from "../../../utils/entity";
import { range } from "@latticexyz/utils";
import { Sounds } from "./Sounds";
import { Inventory } from "./Inventory";
import { CreativeInventory } from "./CreativeInventory";
import {
  ActionBarWrapper,
  INVENTORY_HEIGHT,
  INVENTORY_WIDTH,
} from "./InventoryHud";
import { combineLatest, concat, map, of } from "rxjs";

interface Props {
  claim:
    | ComponentValue<{ stake: Type.Number; claimer: Type.String }, undefined>
    | undefined;
  balance: number;
}

export function registerPersistentNotifications() {
  registerUIComponent(
    "Inventory",
    {
      rowStart: 1,
      rowEnd: 13,
      colStart: 1,
      colEnd: 13,
    },
    (layers) => {
      return concat(
        of(1),
        layers.noa.components.UI.update$.pipe(
          map((e) => (e.value[0]?.showInventory ? null : true))
        )
      );
    },
    (layers) => {
      const {
        network: {
          streams: { balanceGwei$ },
        },
      } = layers;

      const claimer = "todo: remove claiming";
      const canBuild = true;

      const notification =
        balanceGwei$ === 0 ? (
          <>
            <Red>X</Red> you need to request a drip before you can mine or build
            (top right).
          </>
        ) : null;

      return (
        <>
          {notification && (
            <NotificationWrapper>
              <Container>{notification}</Container>
            </NotificationWrapper>
          )}
        </>
      );
    }
  );
}

const NotificationWrapper = styled.div`
  position: absolute;
  top: -25px;
  transform: translate(-50%, -100%);
  left: 50%;
  line-height: 100%;
`;

const Notification = styled.p`
  position: absolute;
  top: -25px;
  width: 100%;
  text-align: center;
`;
