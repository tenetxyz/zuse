import React, { useEffect } from "react";
import Fuse from "fuse.js";
import { useComponentUpdate } from "../../../utils/useComponentUpdate";
import { Layers } from "../../../types";
import { getEntityString } from "@latticexyz/recs";
import { Classifier, ClassifierStoreFilters } from "./ClassifierStore";

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
      contractComponents: { Classifier },
    },
  } = layers;

  const allClassifiers = React.useRef<Classifier[]>([]);
  const filteredClassifiers = React.useRef<Classifier[]>([]); // Filtered based on the specified filters. The user's search box query does NOT affect this.
  const [classifiersToDisplay, setClassifiersToDisplay] = React.useState<Classifier[]>([]);
  const fuse = React.useRef<Fuse<Classifier>>();

  useComponentUpdate(Classifier, () => {
    allClassifiers.current = [];
    const classifierTable = Classifier.values;
    classifierTable.name.forEach((name: string, classifierId) => {
      const description = ""; //classifierTable.description.get(classifierId) ?? "";
      const creator = classifierTable.creator.get(classifierId);
      if (!creator) {
        console.warn("No creator found for classifier", classifierId);
        return;
      }

      allClassifiers.current.push({
        creator: creator,
        name: name,
        description: description,
        classifierId: getEntityString(classifierId),
      } as Classifier);
    });

    // After we have parsed all the classifiers, apply the classifier
    // filters to narrow down the classifiers that will be displayed.
    applyClassifierFilters();
  });

  const applyClassifierFilters = () => {
    // TODO: add classifier filters
    // maybe people will filter classifiers based on their name, description, creator, or voxelTypes

    // only the filtered classifiers can be queried
    const options = {
      includeScore: false,
      // TODO: the creator is just an address. we need to replace it with a readable name
      keys: ["name", "description", "creator"],
    };
    fuse.current = new Fuse(allClassifiers.current, options);

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
