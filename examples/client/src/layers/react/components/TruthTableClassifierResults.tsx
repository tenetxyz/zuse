import { cacheStore$ } from "@latticexyz/network/dev";
import { Classifier } from "./ClassifierStore";
import { useEffect, useRef, useState } from "react";
import { to256BitString, unpackTuple } from "@latticexyz/utils";
import { Creation } from "./CreationStore";
import {
  Entity,
  EntitySymbol,
  Has,
  HasValue,
  getComponentValue,
  getComponentValueStrict,
  runQuery,
} from "@latticexyz/recs";
import { stringToEntity } from "../../../utils/entity";
import { Layers } from "../../../types";
import { serializeWithoutIndexedValues } from "../../../utils/encodeOrDecode";
import { parseTwoKeysFromMultiKeyString } from "@/layers/noa/types";

export interface Props {
  layers: Layers;
  classifier: Classifier;
}

interface TruthTableClassifierResult {
  creation: any; // I didn't bother parsing the creation object from RECS
  blockNumber: number;
  inInterfaces: string;
  outInterfaces: string;
}

export const TruthTableClassifierResults = ({ layers, classifier }: Props) => {
  const {
    network: {
      contractComponents: { TruthTableCR },
      parsedComponents: { ParsedCreationRegistry },
    },
  } = layers;
  //   useObservableValue(cacheStore$);
  const storeEvent = useRef<any>(undefined);
  const [results, setResults] = useState<TruthTableClassifierResult[]>([]);

  useEffect(() => {
    const subscription = cacheStore$.subscribe((event) => {
      storeEvent.current = event;
    });
    return () => subscription.unsubscribe();
  }, [cacheStore$]);

  useEffect(() => {
    // PERF: use a query and just select the values with the same classifierId. right now, we loop through all results and it's O(n)
    const records: TruthTableClassifierResult[] = [];
    const truthTableCrTable = TruthTableCR.values;
    truthTableCrTable.blockNumber.forEach((blockNumber: BigInt, key: EntitySymbol) => {
      const [truthTableId, creationId] = parseTwoKeysFromMultiKeyString(key.description!);
      if (truthTableId !== classifier.classifierId) {
        return;
      }

      const inInterfaces = truthTableCrTable.inInterfaces.get(key);
      if (!inInterfaces) {
        console.warn("No inInterfaces for truthTableId", truthTableId);
        return;
      }

      const outInterfaces = truthTableCrTable.outInterfaces.get(key);
      if (!outInterfaces) {
        console.warn("No outInterfaces for truthTableId", truthTableId);
        return;
      }

      const creation = ParsedCreationRegistry.componentRows.get(stringToEntity(to256BitString(creationId.toString())));

      records.push({
        creation,
        blockNumber: Number(blockNumber),
        inInterfaces,
        outInterfaces,
      });
    });

    setResults(records);
  }, [classifier]);

  return (
    <div className="relative overflow-x-auto">
      <table className="w-full text-sm text-left text-gray-500">
        <thead className="text-xs text-gray-700 uppercase bg-gray-50">
          <tr>
            <th scope="col" className="px-6 py-3">
              Creation Result
            </th>
            <th scope="col" className="px-6 py-3">
              Creation Name
            </th>
          </tr>
        </thead>
        <tbody>
          {results.map((result, index) => (
            <tr key={"creation-" + index} className="bg-white border-b">
              <th scope="row" className="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">
                {/* TODO: this needs to be creation metadata */}
                {result.creation?.name ?? ""}
              </th>
              <td className="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">
                Passed on block {result.blockNumber}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};
