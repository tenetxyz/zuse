import React from "react";
import { registerUIComponent } from "../engine";
import { concat, map, of } from "rxjs";
import styled from "styled-components";

export function registerAdminPanel() {
  registerUIComponent(
    "AdminPanel",
    {
      rowStart: 3,
      rowEnd: 13,
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
      return show ? <div></div> : null;
    }
  );
}

const AdminPanelContainer = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: red;
`;
