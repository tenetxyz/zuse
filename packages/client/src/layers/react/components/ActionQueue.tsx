import React, { useEffect, useRef, useState } from "react";
import { registerUIComponent } from "../engine";
import { getComponentEntities, getComponentValueStrict } from "@latticexyz/recs";
import { map } from "rxjs";
import styled from "styled-components";
import { Action as ActionQueueItem } from "./Action";
import { voxelVariantDataKeyToString } from "../../noa/types";
import { publicClient$, transactionHash$ } from "@latticexyz/network/dev";
import type { PublicClient, Chain } from "viem";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { useComponentUpdate } from "../../../utils/useComponentUpdate";
import { getTransactionResult } from "@latticexyz/dev-tools";
import { toast } from "react-toastify";

const ActionQueueList = styled.div`
  width: 240px;
  height: 100%;
  display: flex;
  flex-grow: 1;
  flex-direction: column;
  justify-content: flex-end;
  gap: 6px;
  padding: 20px;
  margin-left: 70px;

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

const MAX_DESCRIPTION_LEN = 13;

function enforceMaxLen(str: string) {
  if (str.length > MAX_DESCRIPTION_LEN) {
    return str.substring(0, MAX_DESCRIPTION_LEN) + "...";
  }
  return str;
}
type MudPublicClient = PublicClient & { chain: Chain };
export function registerActionQueue() {
  registerTenetComponent({
    rowStart: 6,
    rowEnd: 12,
    columnStart: 10,
    columnEnd: 13,
    Component: ({ layers }) => {
      const {
        network: {
          actions: { Action },
          config: { blockExplorer },
          getVoxelIconUrl,
        },
      } = layers;

      const [_update, setUpdate] = useState<any>(); // by calling setUpdate, it allows us to update the queue
      useComponentUpdate(Action as any, setUpdate); // there's probably a better way to update this, since we get all the compoennt entities below.

      const txRef = useRef<string>();
      const publicClient = useRef<MudPublicClient>();
      useEffect(() => {
        publicClient$.subscribe((client) => {
          if (!client) {
            return;
          }
          publicClient.current = client as MudPublicClient;
        });
      }, []);
      useEffect(() => {
        transactionHash$.subscribe((txHash) => {
          txRef.current = txHash;
          if (!publicClient.current) {
            return;
          }
          // I think our viem version is different, so the PublicClient object is out of date, causing the type error below
          const transactionResultPromise = getTransactionResult(publicClient.current, txHash);
          transactionResultPromise.catch((err) => {
            console.warn("Error getting transaction result", err);
            // Note: we can use the data in err.cause to get specific parts of the error message
            toast(err.shortMessage);
          });
        });
      }, []);

      return (
        <ActionQueueList>
          {[...getComponentEntities(Action)].map((e) => {
            const { state, metadata, txHash } = getComponentValueStrict(Action, e);
            const { actionType, coord, voxelVariantKey, preview } = metadata || {};
            let icon = voxelVariantKey && getVoxelIconUrl(voxelVariantKey);
            if (icon === undefined) {
              icon = preview;
            }
            return (
              <div key={e} className="ActionQueueItem">
                <ActionQueueItem
                  state={state}
                  icon={icon}
                  title={`${actionType} tx`}
                  description={voxelVariantKey ? enforceMaxLen(voxelVariantDataKeyToString(voxelVariantKey)) : ""}
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
    },
  });
}
