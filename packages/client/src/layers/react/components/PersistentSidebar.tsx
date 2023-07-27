import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { calculateChildCoords, calculateParentCoord, getWorldScale } from "../../../utils/coord";
import { useEffect, useState } from "react";
import { setScale } from "../../../layers/noa/systems/createScaleManager";
import { useObservableValue } from "@latticexyz/react";
import { toast } from "react-toastify";
import { VoxelCoord } from "@latticexyz/utils";
import { setComponent, getComponentValue } from "@latticexyz/recs";
import { openSidebar, closeSidebar } from "../../../layers/noa/systems/createInputSystem";
import { Layers } from "../../../types";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faMagnifyingGlassPlus, faMagnifyingGlassMinus, faBars } from "@fortawesome/free-solid-svg-icons";
import styled from "styled-components";


export const SIDEBAR_BACKGROUND_COLOR = "#353535";
export function registerPersistentSidebar() {
  registerTenetComponent({
    // rowStart: 3,
    // rowEnd: 13,
    // columnStart: 1,
    // columnEnd: 3,
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
            <TooltipContainer>
              <Button onClick={() => openSidebar(FocusedUi, SingletonEntity, PersistentNotification, SpawnCreation, noa)} >
                <FontAwesomeIcon icon={faBars} style={{ color: "#C9CACB"}} />
              </Button>
              <TooltipText>Open Sidebar</TooltipText>
            </TooltipContainer>
            <TooltipContainer>
              <Button onClick={zoomIn}>
                <FontAwesomeIcon icon={faMagnifyingGlassPlus} style={{ color: "#C9CACB"}} />
              </Button>
              <TooltipText>Zoom In to Level {worldScale - 1}</TooltipText>
            </TooltipContainer>
            <TooltipContainer>
              <Button onClick={zoomOut}>
                <FontAwesomeIcon icon={faMagnifyingGlassMinus} style={{ color: "#C9CACB"}} />
              </Button>
              <TooltipText>Zoom Out to Level {worldScale + 1}</TooltipText>
            </TooltipContainer>
          </div>

          <div>
            <div>Scale Level: {worldScale}</div>
            {position && (
              <div className="p-5 font-bold">
                x: {Math.round(position.x)} y: {Math.round(position.y)} z: {Math.round(position.z)}
              </div>
            )}
          </div>
        </div>
      );
    },
  });
}

const TooltipText = styled.span`
  visibility: hidden;
  max-width: 120px; // set a maximum width
  background-color: #555;
  color: #fff;
  text-align: center;
  padding: 5px 0;
  border-radius: 6px;
  position: absolute;
  z-index: 1;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%); // center the tooltip
  opacity: 0;
  transition: opacity 0.1s;
  white-space: nowrap; // prevent the text from wrapping
  &:after {
    content: "";
    position: absolute;
    top: 100%;
    left: 50%;
    margin-left: -5px;
    border-width: 5px;
    border-style: solid;
    border-color: #555 transparent transparent transparent;
  }
`;


const TooltipContainer = styled.div`
  position: relative;
  display: inline-block;
  &:hover ${TooltipText} {
    visibility: visible;
    opacity: 1;
  }
`;

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

