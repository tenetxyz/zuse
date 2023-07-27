import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { calculateChildCoords, calculateParentCoord, getWorldScale } from "../../../utils/coord";
import { useEffect, useState } from "react";
import { setScale } from "../../../layers/noa/systems/createScaleManager";
import { useObservableValue } from "@latticexyz/react";
import { toast } from "react-toastify";
import { VoxelCoord } from "@latticexyz/utils";

export const SIDEBAR_BACKGROUND_COLOR = "#353535";
export function registerPersistentSidebar() {
  registerTenetComponent({
    rowStart: 3,
    rowEnd: 13,
    columnStart: 1,
    columnEnd: 3,
    zIndex: 10,
    Component: ({ layers }) => {
      const {
        noa: {
          noa,
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
        // "pointerEvents: all" is needed so when we click on the admin panel, we don't gain focus on the noa canvasvoxelTypes = creationTable.voxelTypes.get(creationId)
        <div className="bg-slate-700 p-5 rounded-tr-md rounded-br-md" style={{ pointerEvents: "all" }}>
          <div>Scale Level: {worldScale}</div>
          {position && (
            <div className="p-5 font-bold">
              x: {Math.round(position.x)} y: {Math.round(position.y)} z: {Math.round(position.z)}
            </div>
          )}
          <button className="cursor-pointer p-5 bg-slate-500" onClick={zoomIn}>
            Zoom in
          </button>
          <button className="cursor-pointer p-5 bg-slate-500" onClick={zoomOut}>
            Zoom out
          </button>
        </div>
      );
    },
  });
}
