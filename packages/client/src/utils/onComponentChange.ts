import {
  Component,
  defineQuery,
  getComponentValue,
  Has,
  isComponentUpdate,
  Metadata,
  Schema,
} from "@latticexyz/recs";
import { useEffect } from "react";

export function onComponentChange<S extends Schema>(
  component: Component<S, Metadata, undefined>,
  onComponentChange: () => void
): void {
  useEffect(() => {
    const queryResult = defineQuery([Has(component)], { runOnInit: false });
    const subscription = queryResult.update$.subscribe((update) => {
      if (isComponentUpdate(update, component)) {
        onComponentChange();
      }
    });
    return () => subscription.unsubscribe();
  }, [component]);
}
