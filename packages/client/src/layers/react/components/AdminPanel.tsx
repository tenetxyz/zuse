import React from "react";
import { registerUIComponent } from "../engine";
import { concat, map, of } from "rxjs";
import styled from "styled-components";
import { CloseableContainer } from "./common";

export function registerAdminPanel() {
  registerUIComponent(
    "AdminPanel",
    {
      rowStart: 2,
      rowEnd: 11,
      colStart: 1,
      colEnd: 4,
    },
    (layers) =>
      layers.noa.components.UI.update$.pipe(
        map((e) => ({ layers, show: e.value[0]?.showAdminPanel }))
      ),
    ({ layers, show }) => {
      const {
        network: { world },
      } = layers;
      return show ? (
        // pointerEvents: all is needed so when we click on the admin panel, we don't gain focus on the noa canvas
        <div
          className="relative z-50 w-full h-full bg-slate-900 p-10 text-white"
          style={{ pointerEvents: "all" }}
        >
          <p className="text-2xl">Admin Panel</p>
          <button
            className="p-5 bg-slate-700 cursor-pointer"
            onClick={() => alert("hi")}
          >
            Download Voxels
          </button>
        </div>
      ) : null;
    }
  );
}
