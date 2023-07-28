import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { calculateChildCoords, calculateParentCoord, getWorldScale } from "../../../utils/coord";
import { useEffect, useState } from "react";
import { setScale } from "../../../layers/noa/systems/createScaleManager";
import { useObservableValue } from "@latticexyz/react";
import { toast } from "react-toastify";
import { VoxelCoord } from "@latticexyz/utils";
import { openSidebar, closeSidebar } from "../../../layers/noa/systems/createInputSystem";
import { Layers } from "../../../types";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faMagnifyingGlassPlus, faMagnifyingGlassMinus, faBars } from "@fortawesome/free-solid-svg-icons";
import styled from "styled-components";
import { SetupContractConfig, getBurnerWallet } from "@latticexyz/std-client";
import { registerBlockExplorer } from "./BlockExplorer";
import { isNetworkComponentUpdateEvent, NetworkComponentUpdate } from "@latticexyz/network";
import { setComponent, ComponentValue, Entity, getComponentValue, SchemaOf } from "@latticexyz/recs";
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
          streams: { playerPosition$ },
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
        }
      } = layers;

      const [worldScale, setWorldScale] = useState<number>(1);

      const position = useObservableValue(playerPosition$);

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
        // The proper way to change the scale is to use a new worldname:
        // we are not calling invalidateChunksInBox (or the deprecated world.invalidateAllChunks) because using the world name is the proper way to do it
        // https://github.com/fenomas/noa/commit/095f42c15aa5b1832739b647523ee620f3606400
        // Note: There is a function in world.js that is a tick loop. This will check to see if the function has changed and properly update the world.
        // noa automatically resets all chunks and reloads them when the worldName changes!
        noa.worldName = newWorldScale.toString();

        teleport(getNewPosition(currentWorldScale));
      };

      const zoomIn = () => {
        setScale(-1, (currentWorldScale) => {
          return calculateChildCoords(getWorldScale(noa) + 1, position!)[0];
        });
      };

      const zoomOut = () => {
        setScale(+1, () => {
          const newPosition = calculateParentCoord(position!, getWorldScale(noa));
          newPosition.y += 1;
          return newPosition;
        });
      };

      return (
        <div className="p-5 flex justify-between items-start" style={{ pointerEvents: "all" }}>
          <div>
            <TooltipProvider delayDuration={100}>
              <Tooltip>
                <TooltipTrigger>
                  <Button onClick={() => openSidebar(FocusedUi, SingletonEntity, PersistentNotification, SpawnCreation, noa)}>
                    <FontAwesomeIcon icon={faBars} style={{ color: "#C9CACB"}} />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  Open Sidebar
                </TooltipContent>
              </Tooltip>
              
              <Tooltip>
                <TooltipTrigger>
                  <Button onClick={zoomIn}>
                    <FontAwesomeIcon icon={faMagnifyingGlassPlus} style={{ color: "#C9CACB"}} />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  Zoom In to Level {worldScale - 1}
                </TooltipContent>
              </Tooltip>

              <Tooltip>
                <TooltipTrigger>
                  <Button onClick={zoomOut}>
                    <FontAwesomeIcon icon={faMagnifyingGlassMinus} style={{ color: "#C9CACB"}} />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  Zoom Out to Level {worldScale + 1}
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </div>
          <div>
            <Card style={{ backgroundColor: "rgba(255, 255, 255, 0.07)", padding: "2px", border: "1px solid rgb(201, 202, 203)"}}>
              <Card style={{ backgroundColor: "rgba(36, 42, 47, 0.8)", border: "2px solid rgb(55, 65, 71)"}}>
                <CardContent className="p-4">
                  <div style = {{marginBottom: "8px"}}>
                    <span>
                      <span className="font-thin px-[0.3rem] py-[0.2rem] font-mono text-xs" style={{color: "#c8c9ca"}}> BRANCH: </span>
                      <span className="font-mono text-sm font-semibold" > {layers.network.worldAddress.slice(2, 11)}... </span>
                    </span>
                  </div>

                  <div style = {{marginBottom: "8px"}}>
                    <span>
                      <span className="font-thin px-[0.3rem] py-[0.2rem] font-mono text-xs" style={{color: "#c8c9ca"}}> LEVEL: </span>
                      <span className="font-mono text-sm font-semibold" > {worldScale} </span>
                    </span>
                  </div>
                  <hr style={{borderTop: "1px solid #c8c9ca", marginBottom: "8px"}}/>
                  <div style = {{marginBottom: "8px"}}>
                    <span>
                      <span className="font-thin px-[0.3rem] py-[0.2rem] font-mono text-xs" style={{color: "#c8c9ca"}}> PLAYER: </span>
                      <span className="font-mono text-sm font-semibold" > { layers.network.network.connectedAddress.get().slice(2, 11) }... </span>
                    </span>
                  </div>
                  <div>
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
                  </div>
                </CardContent>
              </Card>
            </Card>




          </div>
        </div>
      );
    },
  });
}


const Button = styled.button<{ selected?: boolean }>`
  padding: 8px;
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

