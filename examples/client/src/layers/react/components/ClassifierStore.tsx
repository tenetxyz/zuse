import React from "react";
import { Layers } from "../../../types";
import { Entity } from "@latticexyz/recs";
import { TableInfo, useClassifierSearch } from "./useClassifierSearch";
import { CreationStoreFilters } from "./CreationStore";
import { SetState } from "../../../utils/types";
import { InterfaceVoxel } from "../../noa/types";
import { SearchBar } from "./common/SearchBar";
import ClassifierDetails from "./ClassifierDetails";
import { twMerge } from "tailwind-merge";
import { toast } from "react-toastify";
import { Button } from "./common";
import { set } from "@latticexyz/store-cache";
import { RegisterTruthTableClassifier } from "./RegisterTruthTableClassifier";

export interface ClassifierStoreFilters {
  classifierQuery: string;
  creationFilter: CreationStoreFilters;
}

interface Props {
  layers: Layers;
  filters: ClassifierStoreFilters;
  creationsPage: CreationsPage;
  setFilters: SetState<ClassifierStoreFilters>;
  selectedClassifier: Classifier | null;
  setSelectedClassifier: SetState<Classifier | null>;
  setCreationsPage: SetState<CreationsPage>;
}

export enum CreationsPage {
  ALL_CREATIONS,
  CLASSIFIER_CREATIONS,
  REGISTER_TRUTH_TABLE_CLASSIFIER,
}

export interface Classifier {
  name: string;
  description: string;
  classifierId: Entity;
  creator: Entity;
  // functionSelector: string;
  classificationResultTableName: string;
  selectorInterface: InterfaceVoxel[];
  namespace: string;
  truthTableInfo?: TableInfo;
}

const ClassifierStore: React.FC<Props> = ({
  layers,
  filters,
  creationsPage,
  setFilters,
  selectedClassifier,
  setSelectedClassifier,
  setCreationsPage,
}: Props) => {
  const { classifiersToDisplay } = useClassifierSearch({
    layers,
    filters,
  });

  const getCurrentViewName = () => {
    if (selectedClassifier) {
      return selectedClassifier.name;
    }
    if (creationsPage === CreationsPage.REGISTER_TRUTH_TABLE_CLASSIFIER) {
      return "Register Truth Table Classifier";
    }
    return "";
  };

  const classifiersNavClicked = () => {
    setSelectedClassifier(null);
    setCreationsPage(CreationsPage.CLASSIFIER_CREATIONS);
  };

  return (
    <div
      className="flex flex-col h-full p-4"
      style={{
        height: "calc(100% - 3rem)",
      }}
    >
      {!selectedClassifier && (
        <>
          <div className="flex w-full">
            <SearchBar
              value={filters.classifierQuery}
              onChange={(e) => {
                setFilters({ ...filters, classifierQuery: e.target.value });
              }}
            />
          </div>
          <div className="flex w-full mt-5 flex-col items-center">
            <div
              onClick={() => setCreationsPage(CreationsPage.ALL_CREATIONS)}
              className="w-full cursor-pointer block p-2 border border-slate-600 rounded hover:bg-slate-600"
            >
              <h5 className="ml-4 text-lg font-bold tracking-tight">All Creations</h5>
            </div>
          </div>
        </>
      )}
      <nav className={twMerge("flex", selectedClassifier ? "" : "mt-5")} aria-label="Breadcrumb">
        <ol className="inline-flex items-center space-x-1 md:space-x-3">
          <li>
            <div className="flex items-center">
              <a
                onClick={classifiersNavClicked}
                className="cursor-pointer text-sm font-medium text-gray-700 hover:text-blue-600"
              >
                Classifiers
              </a>
            </div>
          </li>
          <li aria-current="page">
            <div className="flex items-center">
              <svg
                className="w-3 h-3 text-gray-400 mx-1"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 6 10"
              >
                <path
                  stroke="currentColor"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="m1 9 4-4-4-4"
                />
              </svg>
              <span className="ml-1 text-sm font-medium text-gray-500">{getCurrentViewName()}</span>
            </div>
          </li>
        </ol>
      </nav>

      {creationsPage === CreationsPage.REGISTER_TRUTH_TABLE_CLASSIFIER && (
        <RegisterTruthTableClassifier layers={layers} />
      )}

      {selectedClassifier ? (
        <ClassifierDetails layers={layers} selectedClassifier={selectedClassifier} />
      ) : (
        <div className="flex w-full h-full mt-5 flex-col gap-5 items-center overflow-scroll">
          {classifiersToDisplay.map((classifier, idx) => {
            return (
              <div
                key={"classifier-" + idx}
                className="w-full cursor-pointer block p-2 border border-slate-600 rounded hover:bg-slate-600"
              >
                <h5 className="ml-4 text-lg font-bold tracking-tight">{classifier.name}</h5>
                <p className="font-normal leading-4">{classifier.description}</p>
                <div className="flex mt-5 gap-2">
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedClassifier(classifier);
                    }}
                    className="text-gray-900 hover:text-white border border-gray-800 hover:bg-gray-900 focus:ring-4 focus:outline-none focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center mr-2 mb-2"
                  >
                    View Details
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
      <Button
        onClick={() => {
          setCreationsPage(CreationsPage.REGISTER_TRUTH_TABLE_CLASSIFIER);
        }}
      >
        Add Boolean Logic Classifier
      </Button>
    </div>
  );
};

export default ClassifierStore;