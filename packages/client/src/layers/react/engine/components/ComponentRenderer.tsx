import React, { useMemo, useState } from "react";
import { observer } from "mobx-react-lite";
import { useLayers, useEngineStore } from "../hooks";
import { filterNullishValues } from "@latticexyz/utils";
import { Cell } from "./Cell";
import styled from "styled-components";
import { GridConfiguration, UIComponent } from "../types";
import { useObservableValue } from "@latticexyz/react";
import { Layers } from "../../../../types";
import { TenetComponentRenderer } from "./TenetComponentRenderer";
import { Lobby } from "../../components/Lobby";

const UIGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(12, 8.33%);
  grid-template-rows: repeat(12, 8.33%);
  position: absolute;
  left: 0;
  top: 0;
  height: 100vh;
  width: 100vw;
  pointer-events: none;
  z-index: 100;
`;

const _UIComponentContainer: React.FC<{
  children: React.ReactNode;
  gridConfig: GridConfiguration;
}> = ({ children, gridConfig }) => {
  const { colStart, colEnd, rowStart, rowEnd } = gridConfig;

  return (
    <Cell
      style={{
        gridRowStart: rowStart,
        gridRowEnd: rowEnd,
        gridColumnStart: colStart,
        gridColumnEnd: colEnd,
      }}
    >
      {children}
    </Cell>
  );
};

export const UIComponentContainer = React.memo(_UIComponentContainer);

const _UIComponentRenderer: React.FC<{
  layers: Layers;
  id: string;
  uiComponent: UIComponent;
}> = ({ layers, id, uiComponent: { requirement, Render, gridConfig } }) => {
  const req = useMemo(() => requirement(layers), [requirement, layers]);
  const state = useObservableValue(req);
  if (!state) return null;

  return (
    <UIComponentContainer key={`component-${id}`} gridConfig={gridConfig}>
      {<Render {...state} />}
    </UIComponentContainer>
  );
};
export const UIComponentRenderer = React.memo(_UIComponentRenderer);

export const ComponentRenderer: React.FC = observer(() => {
  const { UIComponents } = useEngineStore();
  const layers = useLayers();
  if (!layers) return null;

  // if there is no world address param, then show the lobby screen
  const params = new URLSearchParams(window.location.search);
  const worldAddress = params.get("worldAddress");
  // TODO: this is a hack, cause we have already loaded up layers before we show the lobby page.
  // In the future, we should only pass in the registry world to the lobby if the user hasn't selected a world
  if (!worldAddress) {
    return <Lobby layers={layers} />;
  }

  return (
    <UIGrid>
      {filterNullishValues(
        // Iterate through all registered UIComponents
        // and return those whose requirements are fulfilled
        [...UIComponents.entries()].map(([id, uiComponent]) => {
          return (
            <UIComponentRenderer layers={layers} id={id} key={`componentRenderer-${id}`} uiComponent={uiComponent} />
          );
        })
      )}
      {<TenetComponentRenderer layers={layers} />}
    </UIGrid>
  );
});
