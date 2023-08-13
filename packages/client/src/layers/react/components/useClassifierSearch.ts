import React, { useEffect } from "react";
import Fuse from "fuse.js";
import { useComponentUpdate } from "../../../utils/useComponentUpdate";
import { Layers } from "../../../types";
import { Entity, getComponentValue, getEntityString } from "@latticexyz/recs";
import { Classifier, ClassifierStoreFilters } from "./ClassifierStore";
import { to64CharAddress } from "../../../utils/entity";
import { ethers } from "ethers";
import { abiDecode, cleanObjArray, serializeWithoutIndexedValues } from "@/utils/encodeOrDecode";

import { hexToAscii, removeTrailingNulls } from "../../../utils/encodeOrDecode";
import { EMPTY_VOXEL_ENTITY, InterfaceVoxel } from "../../noa/types";
import { keccak256 } from "@latticexyz/utils";

export interface Props {
  layers: Layers;
  filters: ClassifierStoreFilters;
}

export interface ClassifierSearch {
  classifiersToDisplay: Classifier[];
}

export interface TableInfo {
  inputRows: string[];
  outputRows: string[];
  numInputBits: number;
  numOutputBits: number;
}

export const useClassifierSearch = ({ layers, filters }: Props) => {
  const {
    network: {
      components: { FunctionSelectors },
      contractComponents: { TruthTable },
      worldContract,
    },
  } = layers;

  const allClassifiers = React.useRef<Classifier[]>([]);
  const filteredClassifiers = React.useRef<Classifier[]>([]); // Filtered based on the specified filters. The user's search box query does NOT affect this.
  const [classifiersToDisplay, setClassifiersToDisplay] = React.useState<Classifier[]>([]);
  const fuse = React.useRef<Fuse<Classifier>>();

  // Commented out since it's not used
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

  // Here we derive classifiers based on the TruthTable table
  useComponentUpdate(TruthTable, () => {
    allClassifiers.current = [];
    const truthTableTable = TruthTable.values;
    truthTableTable.name.forEach((name: string, classifierId) => {
      const creator = truthTableTable.creator.get(classifierId);
      if (!creator) {
        console.warn("No creator found for classifier", classifierId);
        return;
      }
      const inputRows = truthTableTable.inputRows.get(classifierId);
      if (!inputRows) {
        console.warn("No inputRows found for classifier", classifierId);
        return;
      }
      const outputRows = truthTableTable.outputRows.get(classifierId);
      if (!outputRows) {
        console.warn("No outputRows found for classifier", classifierId);
        return;
      }
      const numInputBits = truthTableTable.numInputBits.get(classifierId);
      if (!numInputBits) {
        console.warn("No numInputBits found for classifier", classifierId);
        return;
      }
      const numOutputBits = truthTableTable.numOutputBits.get(classifierId);
      if (!numOutputBits) {
        console.warn("No numOutputBits found for classifier", classifierId);
        return;
      }
      const interfaceVoxels = getInputInterfaceVoxels(numInputBits).concat(
        getOutputInterfaceVoxels(numInputBits, numOutputBits)
      );

      const tableInfo = {
        inputRows: inputRows.map((row) => row.toString()),
        outputRows: outputRows.map((row) => row.toString()),
        numInputBits: numInputBits,
        numOutputBits: numOutputBits,
      };

      allClassifiers.current.push({
        name: name,
        description: "hi",
        classifierId: getEntityString(classifierId),
        creator: creator as Entity,
        // functionSelector: "TruthTableClassifier",
        classificationResultTableName: "TruthTableCR",
        selectorInterface: interfaceVoxels,
        namespace: "tenet-truth-table", // TODO: we should remove this since namespace isnt' used anymore
        truthTableInfo: tableInfo,
      } as Classifier);
    });
    applyClassifierFilters();
  });

  const getInputInterfaceVoxels = (numInputBits: number) => {
    const poweredInterfaceVoxels = [];
    for (let i = 0; i < numInputBits; i++) {
      poweredInterfaceVoxels.push({
        index: i,
        entity: EMPTY_VOXEL_ENTITY, // not used until the user actually selects a voxel as an interface
        name: "in" + (i + 1),
        desc: "input bit",
      } as InterfaceVoxel);
    }
    return poweredInterfaceVoxels;
  };

  const getOutputInterfaceVoxels = (numInputBits: number, numOutputBits: number) => {
    const outputInterfaceVoxels = [];
    for (let i = 0; i < numOutputBits; i++) {
      outputInterfaceVoxels.push({
        index: numInputBits + i,
        entity: EMPTY_VOXEL_ENTITY, // not used until the user actually selects a voxel as an interface
        name: "output" + (i + 1),
        desc: "ouput bit",
      } as InterfaceVoxel);
    }
    return outputInterfaceVoxels;
  };

  const applyClassifierFilters = () => {
    // TODO: add classifier filters
    // maybe people will filter classifiers based on their name, description, creator, or voxelTypes
    filteredClassifiers.current = allClassifiers.current;

    // only the filtered classifiers can be queried
    const options = {
      includeScore: false,
      // TODO: the creator is just an address. we need to replace it with a readable name
      keys: ["name", "description", "creator"],
    };
    fuse.current = new Fuse(filteredClassifiers.current, options);

    queryForClassifiersToDisplay();
  };
  // recalculate which classifiers are in the display pool when the filters change
  useEffect(applyClassifierFilters, [filters]);

  const queryForClassifiersToDisplay = () => {
    if (!fuse.current) {
      return;
    }
    if (filters.classifierQuery === "") {
      setClassifiersToDisplay(filteredClassifiers.current);
      return;
    }

    const queryResult = fuse.current.search(filters.classifierQuery).map((r) => r.item);
    setClassifiersToDisplay(queryResult);
  };
  React.useEffect(queryForClassifiersToDisplay, [filters.classifierQuery]);

  return {
    classifiersToDisplay,
  };
};
