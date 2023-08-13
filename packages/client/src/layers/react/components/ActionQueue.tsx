import React, { useEffect, useRef, useState } from "react";
import { getComponentEntities, getComponentValueStrict } from "@latticexyz/recs";
import styled from "styled-components";
import { Action as ActionQueueItem } from "./Action";
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
    rowStart: 0,
    rowEnd: 0,
    columnStart: 0,
    columnEnd: 0,
    Component: ({ layers }) => {
      const {
        network: {
          actions: { Action },
          config: { blockExplorer },
          objectStore: { transactionCallbacks },
        },
      } = layers;

      const [_update, setUpdate] = useState<any>(); // by calling setUpdate, it allows us to update the queue
      useComponentUpdate(Action as any, setUpdate); // there's probably a better way to update this, since we get all the component entities below when we call getComponentEntities(Action).

      const txRef = useRef<string>();
      const publicClient = useRef<MudPublicClient>();
      useEffect(() => {
        publicClient$.subscribe((client) => {
          publicClient.current = client as MudPublicClient;
        });
      }, []);

      // listen to the results of the transactions and surface errors as toasts for the user
      useEffect(() => {
        transactionHash$.subscribe((txHash) => {
          txRef.current = txHash;
          if (!publicClient.current) {
            return;
          }
          // I think our viem version is different, so MUD's PublicClient object is out of date, causing the type error below
          const transactionResultPromise = getTransactionResult(publicClient.current, txHash);
          transactionResultPromise
            .then((res) => {
              transactionCallbacks.get(txHash)?.(res.result);
            })
            .catch((err) => {
              if (err.name === "TransactionReceiptNotFoundError") {
                // this error isn't urgent. it may occur when the transaction hasn't been processed on a block yet.
                console.warn("Transaction receipt not found error: ", err.shortMessage);
                // Note: when we call classifiers, the transaction always finishes, but the transaction receipt is not always found. We aren't sure what to listen to learn when it's actually finished. In the meantime, we assume that when we
                // get this error, the classifier has finished. This is why we are calling the callback here (as a hack)
                transactionCallbacks.get(txHash)?.(res.result);
                return;
              }
              console.error("[ActionQueue] Error getting transaction result", err);
              // Note: we can also use the fields in err.cause to get specific parts of the error message
              toast(err.shortMessage);
            })
            .finally(() => {
              transactionCallbacks.delete(txHash);
              if (transactionCallbacks.size > 15) {
                console.warn(
                  `${transactionCallbacks.size} stale transaction callbacks are NOT cleared. This means that we are not cleaning up after every transaction that occurs. We need to find locate WHEN these missing transactions finish`
                );
              }
            });
        });
      }, []);

      // return (
      //   <ActionQueueList>
      //     {[...getComponentEntities(Action)].map((e) => {
      //       const { state, metadata, txHash } = getComponentValueStrict(Action, e);
      //       const { actionType, coord, voxelBaseTypeId, preview } = metadata || {};
      //       let icon = voxelBaseTypeId && getVoxelIconUrl(voxelBaseTypeId);
      //       if (icon === undefined) {
      //         icon = preview;
      //       }
      //       return (
      //         <div key={e} className="ActionQueueItem">
      //           <ActionQueueItem
      //             state={state}
      //             icon={icon}
      //             title={`${actionType} tx`}
      //             description={voxelBaseTypeId ? enforceMaxLen(voxelBaseTypeId) : ""}
      //             link={txHash && blockExplorer + "/tx/" + txHash}
      //           />
      //           {/* TODO: conditionally render this for debugging? */}
      //           {coord ? (
      //             <div className="ActionQueueItemPosition">
      //               <div>X: {coord.x}</div>
      //               <div>Y: {coord.y}</div>
      //               <div>Z: {coord.z}</div>
      //             </div>
      //           ) : null}
      //         </div>
      //       );
      //     })}
      //   </ActionQueueList>
      // );
    },
  });
}
