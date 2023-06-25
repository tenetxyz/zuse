import React from "react";
import { registerUIComponent } from "../engine";
import {
  getComponentEntities,
  getComponentValueStrict,
} from "@latticexyz/recs";
import { map } from "rxjs";
import styled from "styled-components";
import { Action as ActionQueueItem } from "./Action";
import { voxelVariantDataKeyToString } from "../../noa/types";

const ActionQueueList = styled.div`
  width: 240px;
  height: 100%;
  display: flex;
  flex-grow: 1;
  flex-direction: column;
  justify-content: flex-end;
  gap: 6px;
  padding: 20px;

  .ActionQueueItem {
    position: relative;
  }

  .ActionQueueItemPosition {
    position: absolute;
    left: 100%;
    top: 0;
    bottom: 0;
    width: 100px;
    margin-left: 6px;
    color: #fff;
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 4px;
    font-size: 14px;
  }
`;

export function registerActionQueue() {
  registerUIComponent(
    "ActionQueue",
    {
      rowStart: 6,
      rowEnd: 12,
      colStart: 1,
      colEnd: 3,
    },
    (layers) => {
      const {
        network: {
          actions: { Action },
          config: { blockExplorer },
          getVoxelIconUrl,
        },
      } = layers;

      return Action.update$.pipe(
        map(() => ({
          Action,
          blockExplorer,
          getVoxelIconUrl,
        }))
      );
    },
    ({ Action, blockExplorer, getVoxelIconUrl }) => {
      return (
        <ActionQueueList>
          {[...getComponentEntities(Action)].map((e) => {
            const { state, metadata, txHash } = getComponentValueStrict(
              Action,
              e
            );
            const { actionType, coord, voxelVariantKey, preview } = metadata || {};
            let icon = voxelVariantKey && getVoxelIconUrl(voxelVariantKey);
            if (icon == undefined){
              icon = preview;
            }
            return (
              <div key={e} className="ActionQueueItem">
                <ActionQueueItem
                  state={state}
                  icon={icon}
                  title={`${actionType} tx`}
                  description={voxelVariantKey ? voxelVariantDataKeyToString(voxelVariantKey) : ""}
                  link={txHash && blockExplorer + "/tx/" + txHash}
                />
                {/* TODO: conditionally render this for debugging? */}
                {coord ? (
                  <div className="ActionQueueItemPosition">
                    <div>X: {coord.x}</div>
                    <div>Y: {coord.y}</div>
                    <div>Z: {coord.z}</div>
                  </div>
                ) : null}
              </div>
            );
          })}
        </ActionQueueList>
      );
    }
  );
}
