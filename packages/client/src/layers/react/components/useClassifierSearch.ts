import React, { useEffect } from "react";
import Fuse from "fuse.js";
import { useComponentUpdate } from "../../../utils/useComponentUpdate";
import { Layers } from "../../../types";
import { Entity, getComponentValue, getEntityString } from "@latticexyz/recs";
import { Classifier, ClassifierStoreFilters } from "./ClassifierStore";
import { to64CharAddress } from "../../../utils/entity";
import { ethers } from "ethers";
import { abiDecode, cleanObjArray } from "@/utils/encodeOrDecode";

import { hexToAscii, removeTrailingNulls } from "../../../utils/encodeOrDecode";
import { InterfaceVoxel } from "../../noa/types";

export interface Props {
  layers: Layers;
  filters: ClassifierStoreFilters;
}

export interface ClassifierSearch {
  classifiersToDisplay: Classifier[];
}

export const useClassifierSearch = ({ layers, filters }: Props) => {
  const {
    network: {
      components: { FunctionSelectors },
      contractComponents: { Classifier },
      worldContract,
    },
  } = layers;

  // const allClassifiers = React.useRef<Classifier[]>([]);
  // const filteredClassifiers = React.useRef<Classifier[]>([]); // Filtered based on the specified filters. The user's search box query does NOT affect this.
  // const [classifiersToDisplay, setClassifiersToDisplay] = React.useState<Classifier[]>([]);
  // const fuse = React.useRef<Fuse<Classifier>>();

  // useComponentUpdate(Classifier, () => {
  //   allClassifiers.current = [];
  //   const classifierTable = Classifier.values;
  //   classifierTable.name.forEach((name: string, classifierId) => {
  //     const description = classifierTable.description.get(classifierId);
  //     const creator = classifierTable.creator.get(classifierId);
  //     if (!creator) {
  //       console.warn("No creator found for classifier", classifierId);
  //       return;
  //     }

  //     const classifySelector = classifierTable.classifySelector.get(classifierId);
  //     if (!classifySelector) {
  //       console.warn("No classify selector found for classifier", classifierId);
  //       return;
  //     }
  //     const classifierNamespace =
  //       getComponentValue(FunctionSelectors, classifySelector.padEnd(66, "0") as Entity)?.namespace ??
  //       "unknown namespace";

  //     const rawSelectorInterface = classifierTable.selectorInterface.get(classifierId);
  //     const selectorInterface =
  //       (rawSelectorInterface &&
  //         (abiDecode(
  //           "(uint256 index,bytes32 entity,string name,string desc)[]",
  //           rawSelectorInterface
  //         ) as InterfaceVoxel[])) ||
  //       [];
  //     selectorInterface.forEach((voxel) => {
  //       voxel.index = parseInt(voxel.index.toString()); // We want a number here, not a BigInt
  //     });

  //     allClassifiers.current.push({
  //       creator: creator,
  //       name: name,
  //       description: description,
  //       classifierId: getEntityString(classifierId),
  //       classificationResultTableName: classifierTable.classificationResultTableName.get(classifierId),
  //       namespace: removeTrailingNulls(hexToAscii(classifierNamespace.substring(2))), // We need to remove trailing nulls since I think the namespace is padded to 16 chars in mud
  //       selectorInterface: selectorInterface,
  //     } as Classifier);
  //   });

  //   // After we have parsed all the classifiers, apply the classifier
  //   // filters to narrow down the classifiers that will be displayed.
  //   applyClassifierFilters();
  // });

  // const applyClassifierFilters = () => {
  //   // TODO: add classifier filters
  //   // maybe people will filter classifiers based on their name, description, creator, or voxelTypes
  //   filteredClassifiers.current = allClassifiers.current;

  //   // only the filtered classifiers can be queried
  //   const options = {
  //     includeScore: false,
  //     // TODO: the creator is just an address. we need to replace it with a readable name
  //     keys: ["name", "description", "creator"],
  //   };
  //   fuse.current = new Fuse(filteredClassifiers.current, options);

  //   queryForClassifiersToDisplay();
  // };
  // // recalculate which classifiers are in the display pool when the filters change
  // useEffect(applyClassifierFilters, [filters]);

  // const queryForClassifiersToDisplay = () => {
  //   if (!fuse.current) {
  //     return;
  //   }
  //   if (filters.classifierQuery === "") {
  //     setClassifiersToDisplay(filteredClassifiers.current);
  //     return;
  //   }

  //   const queryResult = fuse.current.search(filters.classifierQuery).map((r) => r.item);
  //   setClassifiersToDisplay(queryResult);
  // };
  // React.useEffect(queryForClassifiersToDisplay, [filters.classifierQuery]);
  const classifiersToDisplay: Classifier[] = [
    {
      name: "AND Gate",
      description: "Classifies if this creation is an AND Gate",
      classifierId: "0x12213123" as Entity,
      creator: "0x1231242" as Entity,
      functionSelector: "0x123123123",
      classificationResultTableName: "classifiaction result table name",
      selectorInterface: [],
      namespace: "tenet",
    },
  ];

  return {
    classifiersToDisplay,
  };
};
