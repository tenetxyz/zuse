import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { getWorldScale } from "../../../utils/coord";
import { useEffect, useState } from "react";

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
        noa: { noa },
      } = layers;
      const [worldScale, setWorldScale] = useState<number>(1);

      useEffect(() => {
        noa.on("newWorldName", (_newWorldName: string) => {
          setWorldScale(getWorldScale(noa));
        });
      }, []);

      return (
        <div className="bg-slate-700 p-5 rounded-tr-md rounded-br-md">
          <div>Scale Level: {worldScale}</div>
        </div>
      );
    },
  });
}
