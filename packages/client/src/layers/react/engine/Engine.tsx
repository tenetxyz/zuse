import React from "react";
import { LayerContext, EngineContext } from "./context";
import { EngineStore } from "./store";
import { BootScreen, MainWindow } from "./components";
import { observer } from "mobx-react-lite";
import { useEffect } from "react";
import { useState } from "react";
import { Layers } from "../../../types";

export const Engine: React.FC<{
  layers: any; // TODO: Figure out proper type
  customBootScreen?: React.ReactElement;
}> = observer(({ layers, customBootScreen }) => {
  if (!layers) return customBootScreen || <BootScreen />;

  return (
    <LayerContext.Provider value={layers}>
      <EngineContext.Provider value={EngineStore}>
        <MainWindow />
      </EngineContext.Provider>
    </LayerContext.Provider>
  );
});
