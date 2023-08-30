import React from "react";
import { LayerContext, EngineContext } from "./context";
import { EngineStore } from "./store";
import { BootScreen, ComponentRenderer } from "./components";
import { observer } from "mobx-react-lite";
import { Layers } from "@/types";

export const Engine: React.FC<{
  layers: Partial<Layers>;
  customBootScreen?: React.ReactElement;
}> = observer(({ layers, customBootScreen }) => {
  if (!layers) return customBootScreen || <BootScreen initialOpacity={1} children={null} />;

  return (
    <LayerContext.Provider value={layers}>
      <EngineContext.Provider value={EngineStore}>
        <MainWindow />
      </EngineContext.Provider>
    </LayerContext.Provider>
  );
});

const MainWindow: React.FC = observer(() => {
  return <ComponentRenderer />;
});
