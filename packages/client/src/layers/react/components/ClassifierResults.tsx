import { cacheStore$ } from "@latticexyz/network/dev";
import { Classifier } from "./ClassifierStore";
import { useEffect, useState } from "react";
import { useObservableValue } from "@latticexyz/react";
import { unpackTuple } from "@latticexyz/utils";

export interface Props {
  classifier: Classifier;
}

export const ClassifierResults = ({ classifier }: Props) => {
  //   useObservableValue(cacheStore$);
  const [results, setResults] = useState("");
  useEffect(() => {
    const classifierResultTableKey = `TableId<${classifier.namespace}:${classifier.classificationResultTableName}>`;
    const subscription = cacheStore$.subscribe((storeEvent) => {
      if (!storeEvent) {
        return;
      }
      const componentIndex = storeEvent.components.indexOf(classifierResultTableKey);
      // TODO: this is so inefficient since the client needs to loop through all entities in the world just to find the ones that have the classifier
      const cacheStoreKeys = Array.from(storeEvent.state.keys()).filter((key) => {
        const [component] = unpackTuple(key);
        return component === componentIndex;
      });
      // look at the
      debugger;
      //   console.log("store event", storeEvent);
      // TODO: narrow down to the chain/world we care about?
    });
    return () => subscription.unsubscribe();
  }, [cacheStore$]);

  return (
    <div>
      <div className="flex flex-col">
        <label className="flex items-center space-x-2 ml-2">Classifiers</label>
        <input />
      </div>
    </div>
  );
};
