import FileUpload from "../../../utils/elements/FileUpload";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { useComponentValue } from "@latticexyz/react";

// Why not put the admin panel inside the TenetSidebar? It's because we can have the panel open WHILE we are moving around in the world

export function registerTxResponseListener() {
  registerTenetComponent({
    rowStart: 2,
    rowEnd: 11,
    columnStart: 10,
    columnEnd: 13,
    Component: ({ layers }) => {
      // TODO: I'm not even sure if this logic should have a component. but I'll just put it all here for now
      return null;
    },
  });
}
