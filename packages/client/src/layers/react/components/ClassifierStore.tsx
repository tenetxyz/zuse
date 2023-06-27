import React from "react";
import { Layers } from "../../../types";
import { Entity } from "@latticexyz/recs";
import { useCreationSearch } from "../../../utils/useCreationSearch";
import { useClassifierSearch } from "./useClassifierSearch";
import { CreationStoreFilters } from "./CreationStore";

export interface ClassifierStoreFilters {
  classifierQuery: string;
  creationFilter: CreationStoreFilters;
}

interface Props {
  layers: Layers;
  filters: ClassifierStoreFilters;
  setFilters: React.Dispatch<React.SetStateAction<ClassifierStoreFilters>>;
}

export interface Classifier {
  name: string;
  description: string;
  classifierId: Entity;
  creator: Entity;
  functionSelector: string;
}

const ClassifierStore: React.FC<Props> = ({ layers, filters, setFilters }: Props) => {
  const {
    noa: {
      components: { PersistentNotification, SpawnCreation },
      SingletonEntity,
      api: { toggleInventory },
    },
    network: {
      contractComponents: { Classifier },
      network: { connectedAddress },
      api: { getEntityAtPosition, registerCreation },
    },
  } = layers;

  const { creationsToDisplay } = useCreationSearch({
    layers,
    filters: filters.creationFilter,
  });

  const { classifiersToDisplay } = useClassifierSearch({
    layers,
    filters,
  });

  return (
    <div className="max-w-md mx-auto p-4 text-white flex flex-row content-start float-top h-full min-w-[800px]">
      <div className="flex flex-col">
        <label className="flex items-center space-x-2 ml-2">My Creations</label>
        <div className="flex flex-row">
          <input
            placeholder="Search My Creations"
            className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
            value={filters.creationFilter.search}
            onChange={(e) => {
              setFilters({
                ...filters,
                creationFilter: {
                  ...filters.creationFilter,
                  search: e.target.value,
                },
              });
            }}
          />
        </div>
        <div className="m-2 p-2 flex flex-col">
          {creationsToDisplay.map((creation, idx) => {
            return (
              <div
                key={idx}
                className="border-1 border-solid border-slate-700 p-2 mb-2 flex flex-row whitespace-nowrap justify-around break-all justify-start space-x-5"
              >
                <p>{creation.name}</p>
                <p>{creation.description}</p>
                <p className="">{creation.relativePositions.length} voxels</p>
                <p className="break-all break-words">{creation.creator.substr(50)}</p>
              </div>
            );
          })}
        </div>
      </div>
      <div className="flex flex-col">
        <label className="flex items-center space-x-2 ml-2">Classifiers</label>
        <input
          placeholder="Search my classifiers"
          className="bg-slate-700 p-1 ml-2 focus:outline-slate-700 border-1 border-solid mb-1 "
          value={filters.classifierQuery}
          onChange={(e) => {
            setFilters({ ...filters, classifierQuery: e.target.value });
          }}
        />
        <div className="m-2 p-2 flex flex-col">
          {classifiersToDisplay.map((classifier, idx) => {
            return (
              <div
                key={idx}
                className="border-1 border-solid border-slate-700 p-2 mb-2 flex flex-row whitespace-nowrap justify-around break-all justify-start space-x-5"
              >
                <p>{classifier.name}</p>
                <p>{classifier.description}</p>
                <p className="break-all break-words">{classifier.creator.substring(10)}</p>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default ClassifierStore;
