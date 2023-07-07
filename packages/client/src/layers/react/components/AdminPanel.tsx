import FileUpload from "../../../utils/components/FileUpload";
import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { useComponentValue } from "@latticexyz/react";

// Why not put the admin panel inside the TenetSidebar? It's because we can have the panel open WHILE we are moving around in the world

export function registerAdminPanel() {
  registerTenetComponent({
    rowStart: 2,
    rowEnd: 11,
    columnStart: 10,
    columnEnd: 13,
    Component: ({ layers }) => {
      const {
        noa: {
          components: { UI },
          SingletonEntity,
        },
        network: {
          contractComponents: { VoxelTypeRegistry },
        },
      } = layers;

      const downloadVoxels = () => {
        const voxelPrototype = componentToJson(VoxelTypeRegistry);
        saveObjectAsFile("voxels.json", {
          voxelPrototype,
        });
      };

      interface JsonComponent {
        [key: string]: any;
      }
      const componentToJson = (component: any): JsonComponent => {
        const entries = component.values.value;
        const res: JsonComponent = {};
        for (const [key, value] of entries) {
          res[key.description] = value;
        }
        return res;
      };

      const onImportVoxel = (text: string) => {
        console.log(text);
      };

      // from https://stackoverflow.com/questions/19721439/download-json-object-as-a-file-from-browser
      const saveObjectAsFile = (filename: string, dataObjToWrite: object) => {
        const blob = new Blob([JSON.stringify(dataObjToWrite)], {
          type: "text/json",
        });
        const link = document.createElement("a");

        link.download = filename;
        link.href = window.URL.createObjectURL(blob);
        link.dataset.downloadurl = ["text/json", link.download, link.href].join(":");

        const evt = new MouseEvent("click", {
          view: window,
          bubbles: true,
          cancelable: true,
        });

        link.dispatchEvent(evt);
        link.remove();
      };

      const isShown = useComponentValue(UI, SingletonEntity)?.showAdminPanel;
      return isShown ? (
        // "pointerEvents: all" is needed so when we click on the admin panel, we don't gain focus on the noa canvas
        <div className="relative z-50 w-full h-full bg-slate-800 p-10 " style={{ pointerEvents: "all" }}>
          <p className="text-2xl">Admin Panel</p>
          <button className="p-5 bg-slate-700 w-full cursor-pointer" onClick={downloadVoxels}>
            Download Voxels
          </button>
          <FileUpload buttonText={"Upload Voxels"} onFileUpload={onImportVoxel} />
        </div>
      ) : null;
    },
  });
}
