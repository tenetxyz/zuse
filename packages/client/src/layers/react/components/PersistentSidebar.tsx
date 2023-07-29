import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { calculateChildCoords, calculateParentCoord, getWorldScale } from "../../../utils/coord";
import React, { useEffect, useState, useRef } from "react";
import { useObservableValue } from "@latticexyz/react";
import { toast } from "react-toastify";
import { VoxelCoord } from "@latticexyz/utils";
import { openSidebar, closeSidebar } from "../../../layers/noa/systems/createInputSystem";
import { Layers } from "../../../types";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faArrowUp , faArrowDown, faBars } from "@fortawesome/free-solid-svg-icons";
import styled from "styled-components";
import { SetupContractConfig, getBurnerWallet } from "@latticexyz/std-client";
import { registerBlockExplorer } from "./BlockExplorer";
import { isNetworkComponentUpdateEvent, NetworkComponentUpdate } from "@latticexyz/network";
import { setComponent, ComponentValue, Entity, getComponentValue, SchemaOf, getComponentEntities, getComponentValueStrict } from "@latticexyz/recs";
import { filter, scan, merge, map } from "rxjs";
import { registerUIComponent } from "../engine";
import { filterNullish } from "@latticexyz/utils";
import { voxelTypeToEntity, entityToVoxelType } from "../../noa/types";
import { AIR_ID } from "../../network/api/terrain/occurrence";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Border } from "./common";
import { config } from "@fortawesome/fontawesome-svg-core";
import { Network } from "lucide-react";
import { Action as ActionQueueItem } from "./Action";
import { publicClient$, transactionHash$ } from "@latticexyz/network/dev";
import type { PublicClient, Chain } from "viem";
import { useComponentUpdate } from "../../../utils/useComponentUpdate";
import { getTransactionResult } from "@latticexyz/dev-tools";
import { Badge } from "@/components/ui/badge";


type BlockEvent = {
  blockNumber: number;
  voxelTypeKey?: string;
  action?: "add" | "remove";
};

type BlockSummaryElement = [
  number, // block number
  {
    [voxelType: string]: {
      add?: number;
      remove?: number;
    };
  }
];

type BlockSummary = BlockSummaryElement[];

const BlockExplorerContainer = styled.div`
  display: flex;
  justify-content: flex-end;
  flex-direction: row-reverse;
  padding: 8px;
  overflow: hidden;
  // background: linear-gradient(180deg, rgba(31, 31, 31, 0.6) 0%, rgba(31, 31, 31, 0) 75%);
  font-size: 0.8rem;

  .BlockExplorer-Block {
    border-left: 2px solid rgba(31, 31, 31, 0.3);
    position: relative;
    margin-bottom: 1em;
    pointer-events: all;
    cursor: pointer;
  }
  .BlockExplorer-BlockNumber {
    position: absolute;
    bottom: -1em;
    left: -2px;
    border-left: 2px solid rgba(31, 31, 31, 0.3);
    height: 1em;
    padding-left: 3px;
    padding-top: 3px;
  }
  .BlockExplorer-Actions {
    height: 20px;
    display: flex;
    padding: 0 1px;
  }
  .BlockExplorer-Action {
    position: relative;
    margin: 0 1px;
    width: 20px;
  }
  .BlockExplorer-Action img {
    height: 100%;
    aspect-ratio: 1;
    object-fit: cover;
    border-radius: 2px;
  }
  .BlockExplorer-ActionIcon {
    position: absolute;
    inset: 0;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  .BlockExplorer-ActionIcon--remove {
    color: hsl(0, 100%, 80%);
  }
  .BlockExplorer-ActionIcon--add {
    color: hsl(100, 100%, 80%);
  }
`;

const ActionQueueList = styled.div`
  width: 200px;
  max-height: 80px;
  overflow-y: scroll;
  display: flex;
  flex-grow: 1;
  flex-direction: column;
  gap: 2px;

  .ActionQueueItem {
    position: relative;
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


export function registerPersistentSidebar() {
  registerTenetComponent({
    rowStart: 1,
    rowEnd: 1,
    columnStart: 1,
    columnEnd: 13,
    zIndex: 10,
    Component: ({ layers }) => {
      const {
        noa: {
          noa,
          components: {
            SelectedSlot,
            FocusedUi,
            Tutorial,
            PreTeleportPosition,
            VoxelSelection,
            SpawnCreation,
            PersistentNotification,
            VoxelInterfaceSelection,
            SpawnToClassify,
          },
          SingletonEntity,
          api: { teleport },
          streams: { playerPosition$, zoomEvent$ },
        },
        network:{
          network:{connectedAddress},          
          ecsEvent$,
          mappings,
          contractComponents: { VoxelType },
          network: { blockNumber$ },
          world,
          config: { blockExplorer },
          getVoxelIconUrl,
          actions: { Action },
          objectStore: { transactionCallbacks },
        }
      } = layers;

      const [summary, setSummary] = useState<BlockSummary>([]);
      useEffect(() => {
        const subscription = merge(
          blockNumber$.pipe(map<number, BlockEvent>((blockNumber) => ({ blockNumber }))),
          ecsEvent$
            .pipe(filter(isNetworkComponentUpdateEvent))
            .pipe(filter(({ txHash }) => txHash !== "worker" && txHash !== "cache"))
            .pipe(
              map<NetworkComponentUpdate, BlockEvent | undefined>(({ blockNumber, component, value, entity }) => {
                const componentKey = mappings[component];

                if (componentKey === "Position") {
                  const voxelType = entity !== null ? getComponentValue(VoxelType, entity) : undefined;
                  if (!voxelType) {
                    return;
                  }
                  const voxelTypeKey = voxelTypeToEntity(voxelType);
    
                  if (value) {
                    return {
                      blockNumber,
                      voxelTypeKey,
                      action: "add",
                    };
                  }
                }
              })
            )
            .pipe(filterNullish())
        )
          .pipe(
            filter(
              (update) =>
                update.voxelTypeKey === undefined ||
                entityToVoxelType(update.voxelTypeKey as Entity).voxelTypeId !== AIR_ID
            )
          )
          .pipe(
            scan<BlockEvent, BlockSummary>((summary, event) => {
              const block =
                summary.find(([blockNumber]) => event.blockNumber === blockNumber) ||
                ([event.blockNumber, {}] as BlockSummaryElement);
              const otherBlocks = summary.filter(([blockNumber]) => event.blockNumber !== blockNumber) as BlockSummary;
    
              if (event.voxelTypeKey && event.action) {
                block[1][event.voxelTypeKey] = block[1][event.voxelTypeKey] || {
                  [event.action]: 0,
                };
                const current = block[1][event.voxelTypeKey][event.action] || 0;
                block[1][event.voxelTypeKey][event.action] = current + 1;
              }
    
              return [...otherBlocks, block].slice(-500);
            }, [] as BlockSummary)
          )
          .subscribe(newSummary => {
            setSummary(newSummary);
          });
    
        // Cleanup on unmount
        return () => subscription.unsubscribe();
      }, [blockNumber$, ecsEvent$, mappings, VoxelType, getVoxelIconUrl]);
    

      const [worldScale, setWorldScale] = useState<number>(1);

      const position = useObservableValue(playerPosition$);

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


      useEffect(() => {
        noa.on("newWorldName", (_newWorldName: string) => {
          setWorldScale(getWorldScale(noa));
        });
      }, []);

      const setScale = (scaleDiff: number, getNewPosition: (currentWorldScale: number) => VoxelCoord) => {
        const {
          noa: { noa },
        } = layers;
        const currentWorldScale = parseInt(noa.worldName);
        const newWorldScale = currentWorldScale + scaleDiff;
        if (newWorldScale === 0) {
          toast("you can't go any smaller than level 1!");
          return;
        }
        if (!position) {
          toast("you can't change the scale unless you a position!");
          return;
        }

        const isZoomingIn = scaleDiff === -1;
        zoomEvent$.next(isZoomingIn); // trigger zooming animation

        // The proper way to change the scale is to use a new worldname:
        // we are not calling invalidateChunksInBox (or the deprecated world.invalidateAllChunks) because using the world name is the proper way to do it
        // https://github.com/fenomas/noa/commit/095f42c15aa5b1832739b647523ee620f3606400
        // Note: There is a function in world.js that is a tick loop. This will check to see if the function has changed and properly update the world.
        // noa automatically resets all chunks and reloads them when the worldName changes!
        setTimeout(() => {
          // only change the world name after the zooming animation fades to black (so the user doesn't see the world unload)
          noa.worldName = newWorldScale.toString();

          teleport(getNewPosition(currentWorldScale));
        }, 200);
      };

      const zoomIn = (event: React.MouseEvent<HTMLButtonElement>) => {
        (event.target as HTMLElement).blur(); // lose focus on the element
        setScale(-1, (currentWorldScale) => {
          return calculateChildCoords(currentWorldScale + 1, position!)[0];
        });
      };

      const zoomOut = (event: React.MouseEvent<HTMLButtonElement>) => {
        (event.target as HTMLElement).blur();
        setScale(+1, (currentWorldScale) => {
          const newPosition = calculateParentCoord(position!, currentWorldScale);
          newPosition.y += 1;
          return newPosition;
        });
      };   

      return (
        <div className="p-5 flex justify-between items-start" style={{ pointerEvents: "all" }}>
          <div>
            <div>
              <TooltipProvider delayDuration={100} >
                <Tooltip>
                  <TooltipTrigger>
                    <Button style={{ margin: "0", padding: "8px" }} onClick={() => openSidebar(FocusedUi, SingletonEntity, PersistentNotification, SpawnCreation, noa)}>
                      <FontAwesomeIcon icon={faBars} style={{ color: "#C9CACB"}} />
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent side="right">
                    Open Sidebar
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>
            </div>
            <Badge style={{ padding: "4px 2px", border: "0.5px solid #C9CACB", borderRadius: "4px", marginTop: "8px", backgroundColor: "#ffffff12", backdropFilter: "blur(2px)", textShadow: "1px 1px 2px rgba(0, 0, 0, 0.5)" }}>
              <TooltipProvider delayDuration={100}>
                <span>
                  <Badge variant="secondary" style={{borderRadius: "4px", paddingLeft: "4px", paddingRight: "4px"}}> LEVEL: {worldScale} </Badge>
                </span>
                <Tooltip>
                  <TooltipTrigger>
                    <Button onClick={zoomIn}>
                      <FontAwesomeIcon icon={faArrowDown} style={{ color: "#C9CACB"}} />
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent>
                    Zoom In to Level {worldScale - 1}
                  </TooltipContent>
                </Tooltip>
                <Tooltip>
                  <TooltipTrigger>
                    <Button onClick={zoomOut}>
                      <FontAwesomeIcon icon={faArrowUp} style={{ color: "#C9CACB"}} />
                    </Button>
                  </TooltipTrigger>
                  <TooltipContent>
                    Zoom Out to Level {worldScale + 1}
                  </TooltipContent>
              </Tooltip>
            </TooltipProvider>
            </Badge>
          </div>
          <div>
            <Badge style={{ padding: "4px 2px", border: "0.5px solid #C9CACB", borderRadius: "4px", marginTop: "8px", backgroundColor: "#ffffff12", backdropFilter: "blur(2px)"}}>
                <CardContent className="p-2">
                  <div style = {{marginBottom: "4px", maxWidth: "200px", overflow: "hidden"}}>
                    <Badge variant="secondary" style={{borderRadius: "4px", paddingLeft: "4px", paddingRight: "4px", textShadow: "1px 1px 2px rgba(0, 0, 0, 0.5)"}}> BRANCH: {layers.network.worldAddress.slice(0, 10)}... </Badge> 
                    <BlockExplorerContainer>
                          {summary.map(([blockNumber, block]) => (
                            <div
                              key={blockNumber}
                              className="BlockExplorer-Block"
                              // onClick={() => window.open(blockExplorer + "/block/" + blockNumber)}
                            >
                              {blockNumber % 16 === 0 ? <div className="BlockExplorer-BlockNumber">{blockNumber}</div> : null}
                              <div className="BlockExplorer-Actions">
                                {Object.entries(block).map(([voxelTypeKey, counts]) => {
                                  const voxelType = entityToVoxelType(voxelTypeKey as Entity);
                                  const voxelIconUrl = getVoxelIconUrl(voxelType.voxelVariantTypeId);
                                  return (
                                    <React.Fragment key={voxelTypeKey}>
                                      {counts.add ? (
                                        <div className="BlockExplorer-Action">
                                          <img src={voxelIconUrl} />
                                          <div className="BlockExplorer-ActionIcon BlockExplorer-ActionIcon--add">+{counts.add}</div>
                                        </div>
                                      ) : null}
                                      {counts.remove ? (
                                        <div className="BlockExplorer-Action">
                                          <img src={voxelIconUrl} />
                                          <div className="BlockExplorer-ActionIcon BlockExplorer-ActionIcon--remove">
                                            -{counts.remove}
                                          </div>
                                        </div>
                                      ) : null}
                                    </React.Fragment>
                                  );
                                })}
                              </div>
                            </div>
                          ))}
                    </BlockExplorerContainer>
                  </div>
                  <hr style={{borderTop: "1px solid rgb(201, 202, 203, 0.5)", marginBottom: "4px"}}/>
                  {/* <div>
                    {position && (
                      <span>
                        <span>
                          <span className="font-thin px-[0.3rem] py-[0.2rem] font-mono text-xs" style={{color: "#c8c9ca"}}> X: </span>
                          <span className="font-mono text-sm font-semibold" > {Math.round(position.x)} </span>
                        </span>
                        <span>
                          <span className="font-thin px-[0.3rem] py-[0.2rem] font-mono text-xs" style={{color: "#c8c9ca"}}> Y: </span>
                          <span className="font-mono text-sm font-semibold" > {Math.round(position.y)} </span>
                        </span>
                        <span>
                          <span className="font-thin px-[0.3rem] py-[0.2rem] font-mono text-xs" style={{color: "#c8c9ca"}}> Z: </span>
                          <span className="font-mono text-sm font-semibold" > {Math.round(position.z)} </span>
                        </span>
                      </span>
                      )}
                  </div> */}
                  <Badge variant="secondary" style={{borderRadius: "4px", paddingLeft: "4px", paddingRight: "4px", textShadow: "1px 1px 2px rgba(0, 0, 0, 0.5)"}}> PLAYER: {layers.network.network.connectedAddress.get().slice(0, 10)}... </Badge> 
                  <ActionQueueList>
                    {[...getComponentEntities(Action)].reverse().map((e) => {
                      const { state, metadata, txHash } = getComponentValueStrict(Action, e);
                      const { actionType, coord, voxelVariantTypeId, preview } = metadata || {};
                      let icon = voxelVariantTypeId && getVoxelIconUrl(voxelVariantTypeId);
                      if (icon === undefined) {
                        icon = preview;
                      }
                      return (
                        <div key={e} className="ActionQueueItem">
                          <ActionQueueItem
                            state={state}
                            icon={icon}
                            title={`${actionType} tx`}
                          />
                        </div>
                      );
                    })}
                  </ActionQueueList>
                </CardContent>
            </Badge>
          </div>
        </div>
      );
    },
  });
}


const Button = styled.button<{ selected?: boolean }>`
  padding: 4px 8px;
  margin: 0 4px;
  border: 2px solid #374147;
  background-color: rgba(36, 42, 47, 1);
  border-radius: 8px;
  transition: box-shadow 0.3s ease;
  box-shadow: ${(p) => p.selected ? '#C9CACB 0px 0px 20px 5px' : 'none'};
  &:hover {
    box-shadow: 0 2px 5px 0 rgba(0, 0, 0, 0.1);
    transform: scale(1.05);
  }
`;