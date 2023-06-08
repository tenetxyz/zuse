import React, { useEffect } from "react";
import { registerUIComponent } from "../engine";
import { combineLatest, concat, map, of } from "rxjs";
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
    (layers) => {
      const {
        network: {
          contractComponents: { ItemPrototype },
        },
        noa: {
          components: { UI },
        },
      } = layers;

      const ItemPrototype$ = ItemPrototype.update$;

      const showAdminPanel = UI.update$.pipe(
        map((e) => ({ show: e.value[0]?.showAdminPanel }))
      );

      return combineLatest<
        [ObservableType<typeof chunk$>, ObservableType<typeof showAdminPanel$>]
      >([ItemPrototype$, showAdminPanel]).pipe(
        map((props) => ({ props, layers }))
      );
    },

    ({ props, layers }) => {
      const {
        network: { world },
      } = layers;
      const [ItemProtype$, showAdminPanel] = props;

      useEffect(() => {
        const subscription = ItemProtype$.subscribe((iprotype) => {
          console.log(iprotype);
        });
        return () => subscription?.unsubscribe();
      }, []);

      return showAdminPanel.show ? (
        // "pointerEvents: all" is needed so when we click on the admin panel, we don't gain focus on the noa canvas
        <div
          className="relative z-50 w-full h-full bg-slate-900 p-10 text-white"
          style={{ pointerEvents: "all" }}
        >
          <p className="text-2xl">Admin Panel</p>
          <button
            className="p-5 bg-slate-700 cursor-pointer"
            onClick={() => console.log("hi")}
          >
            Download Voxels
          </button>
        </div>
      ) : null;
    }
  );
}
