import { cacheStore$ } from "@latticexyz/network/dev";
import { Classifier } from "./ClassifierStore";
import { useEffect, useRef, useState } from "react";
import { to256BitString, unpackTuple } from "@latticexyz/utils";
import { Creation } from "./CreationStore";
import { getComponentValue } from "@latticexyz/recs";
import { stringToEntity } from "../../../utils/entity";
import { Layers } from "../../../types";
import { serializeWithoutIndexedValues } from "../../../utils/encodeOrDecode";

export interface Props {
  layers: Layers;
  classifier: Classifier;
}

interface ClassifierResult {
  creation: Creation | undefined;
  record: string;
}

export const ClassifierResults = ({ layers, classifier }: Props) => {
  const {
    network: {
      contractComponents: { Creation },
    },
  } = layers;
  //   useObservableValue(cacheStore$);
  const storeEvent = useRef<any>(undefined);
  const [results, setResults] = useState<ClassifierResult[]>([]);

  useEffect(() => {
    const subscription = cacheStore$.subscribe((event) => {
      storeEvent.current = event;
    });
    return () => subscription.unsubscribe();
  }, [cacheStore$]);

  // This method to use the cacheStore to get the values from deployed tables (after the initial deploy) is taken from the mud dev tools:
  // https://github.com/latticexyz/mud/blob/73e200cc8bc2e28aa927637a0cbd55b71c1608a1/packages/dev-tools/src/tables/Table.tsx#L29
  useEffect(() => {
    const classifierResultTableKey = `TableId<${classifier.namespace}:${classifier.classificationResultTableName}>`;
    if (!storeEvent.current) {
      return;
    }
    const componentIndex = storeEvent.current.componentToIndex.get(classifierResultTableKey);
    if (!componentIndex) {
      // console.warn(`cannot find component index for classifier result table=${classifierResultTableKey}`);
      // this case may happen if NOBODY has submitted to the classifier yet (cause by default, the table is only seen by the client when there are records in it)
      setResults([]);
      return;
    }
    // TODO: this is so inefficient since the client needs to loop through all entities in the world just to find the ones that have the classifier
    const cacheStoreKeys = Array.from(storeEvent.current.state.keys()).filter((key) => {
      const [component] = unpackTuple(key);
      return component === componentIndex;
    });

    const records = cacheStoreKeys
      .map((cacheStoreKey) => [
        cacheStoreKey,
        serializeWithoutIndexedValues(storeEvent.current.state.get(cacheStoreKey) ?? ""),
      ])
      .filter(([_, record]) => record !== "")
      .map(([cacheStoreKey, record]) => {
        const [_componentIndex, entityIndex] = unpackTuple(cacheStoreKey);
        const creationId = storeEvent.current.entities[entityIndex];
        const creation = getComponentValue(Creation, stringToEntity(to256BitString(creationId.toString())));
        return {
          creation,
          record,
        };
      });

    setResults(records as ClassifierResult[]);
  }, [classifier]);

  return (
    <div>
      <div className="flex flex-col">
        <label className="flex items-center space-x-2 ml-2">Results</label>
        {results.map((result, index) => (
          <div key={index} className="flex items-center space-x-2 ml-2">
            <p>{result.creation?.name ?? ""}</p>
            <p>{result.record}</p>
          </div>
        ))}
      </div>
    </div>
  );
};