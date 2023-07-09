import { cacheStore$ } from "@latticexyz/network/dev";
import { Classifier } from "./ClassifierStore";
import { useEffect, useState } from "react";
import { useObservableValue } from "@latticexyz/react";
import { to256BitString, unpackTuple } from "@latticexyz/utils";
import { jsonStringifyWithBigInt } from "../../../utils/encodeOrDecode";
import { Creation } from "./CreationStore";
import { getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { stringToEntity, to64CharAddress } from "../../../utils/entity";
import { Layers } from "../../../types";

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
  const [results, setResults] = useState<ClassifierResult[]>([]);
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

      // TODO: should we remove all numeric keys in the json object? We should test more. If they are just duplicates of the keys (that are strings), then we should remove them
      const records = cacheStoreKeys
        .map((cacheStoreKey) => [cacheStoreKey, jsonStringifyWithBigInt(storeEvent.state.get(cacheStoreKey) ?? "")])
        .filter(([_, record]) => record !== "")
        .map(([cacheStoreKey, record]) => {
          const [_componentIndex, entityIndex] = unpackTuple(cacheStoreKey);
          const creationId = storeEvent.entities[entityIndex];
          const creation = getComponentValue(Creation, stringToEntity(to256BitString(creationId.toString())));
          return {
            creation,
            record,
          };
        });

      setResults(records as ClassifierResult[]);
    });
    return () => subscription.unsubscribe();
  }, [cacheStore$, classifier]);

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
