import { Component, ComponentUpdate, defineQuery, Has, isComponentUpdate, Metadata, Schema } from "@latticexyz/recs";
import { useEffect } from "react";

// Runs a function whenever a component/table receives update
export function useComponentUpdate<S extends Schema>(
  component: Component<S, Metadata, undefined>,
  onComponentUpdate: (update: ComponentUpdate<S, undefined>) => void
): void {
  useEffect(() => {
    const queryResult = defineQuery([Has(component)], { runOnInit: true });
    const subscription = queryResult.update$.subscribe((update) => {
      if (isComponentUpdate(update, component)) {
        onComponentUpdate(update);
      }
    });
    return () => subscription.unsubscribe();
  }, [component]);
}
