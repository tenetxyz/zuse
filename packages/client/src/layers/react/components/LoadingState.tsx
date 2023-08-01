import React from "react";
import { BootScreen, registerUIComponent } from "../engine";
import { concat, map } from "rxjs";
import { getComponentValue } from "@latticexyz/recs";
import { SingletonID, SyncState } from "@latticexyz/network";
import styled from "styled-components";
import { LoadingBar } from "./common";
import { useStream } from "@/utils/stream";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";

export function registerLoadingState() {
  registerTenetComponent({
    rowStart: 1,
    rowEnd: 12,
    columnStart: 1,
    columnEnd: 12,
    Component: ({ layers }) => {
      const {
        components: { LoadingState },
        world,
        streams: { doneSyncing$ },
      } = layers.network;

      // const GodEntityIndex = world.entityToIndex.get(SingletonID);
      const GodEntityIndex = SingletonID;

      const isDoneSyncingWorlds = useStream(doneSyncing$);

      // TODO: set the percentage
      // const loadingState = GodEntityIndex == null ? null : getComponentValue(LoadingState, GodEntityIndex);
      // Maybe for now, we just show the percentage of the LoadingState of the world
      if (!isDoneSyncingWorlds) {
        return (
          <BootScreen initialOpacity={1}>
            Loading
            <LoadingContainer />
          </BootScreen>
        );
      }
      return null;
    },
  });
}

const LoadingContainer = styled.div`
  display: grid;
  justify-items: start;
  justify-content: start;
  align-items: center;
  height: 30px;
  width: 100%;
  grid-gap: 20px;
  grid-template-columns: auto 1fr;
`;

const Loading = styled(LoadingBar)`
  width: 100%;
`;
