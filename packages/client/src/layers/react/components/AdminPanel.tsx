import React, { useEffect } from "react";
import { registerUIComponent } from "../engine";
import { combineLatest, concat, map, of } from "rxjs";
import styled from "styled-components";
import { CloseableContainer } from "./common";
import FileUpload from "../../../utils/components/FileUpload";

export function registerAdminPanel() {
  registerUIComponent(
    "AdminPanel",
    {
      rowStart: 2,
      rowEnd: 11,
      colStart: 1,
      colEnd: 4,
    },
    (layers) => layers.noa.components.UI.update$.pipe(map((e) => ({ layers, show: e.value[0]?.showAdminPanel }))),
    ({ layers, show }) => {
      const {
        components: { VoxelTypeRegistry },
      } = layers.network;
      console.log("admin panel rerender");

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

      return show ? (
        // "pointerEvents: all" is needed so when we click on the admin panel, we don't gain focus on the noa canvas
        <div className="relative z-50 w-full h-full bg-slate-100 p-10 text-white" style={{ pointerEvents: "all" }}>
          <p className="text-2xl">Admin Panel</p>
          <button className="p-5 bg-slate-700 w-full cursor-pointer" onClick={downloadVoxels}>
            Download Voxels
          </button>
          <FileUpload buttonText={"Upload Voxels"} onFileUpload={onImportVoxel} />
        </div>
      ) : null;
    }
  );
}
