import React, { useEffect } from "react";
import { Layers } from "../../../types";
import { Entity, getComponentValue, setComponent } from "@latticexyz/recs";
import { useCreationSearch } from "../../../utils/useCreationSearch";
import { useClassifierSearch } from "./useClassifierSearch";
import { Creation, CreationStoreFilters } from "./CreationStore";
import { useComponentValue } from "@latticexyz/react";
import { SetState } from "../../../utils/types";
import {
  VoxelTypeDataKey,
  entityToVoxelType,
  voxelTypeDataKeyToVoxelVariantDataKey,
  voxelTypeToEntity,
} from "../../noa/types";
import { stringToVoxelCoord } from "../../../utils/coord";
import { SearchBar } from "./common/SearchBar";
import { Classifier } from "./ClassifierStore";
import { twMerge } from "tailwind-merge";
import { TargetedBlock, getTargetedSpawnId } from "../../../utils/voxels";
import { stringToEntity } from "../../../utils/entity";
import { abiDecode } from "../../../utils/abi";

interface Props {
  layers: Layers;
  selectedCreation: Creation | null;
  setSelectedCreation: SetState<Creation | null>;
  setShowAllCreations: SetState<boolean>;
}

const CreationDetails: React.FC<Props> = ({
  layers,
  selectedCreation,
  setSelectedCreation,
  setShowAllCreations,
}: Props) => {
  const {
    noa: {
      noa,
      components: { VoxelSelection, VoxelInterfaceSelection },
      SingletonEntity,
    },
    network: {
      components: { VoxelType, Creation },
      api: { getEntityAtPosition, classifyCreation },
      getVoxelIconUrl,
    },
  } = layers;

  const renderVoxelTypes = () => {
    if (selectedCreation === null) {
      return null;
    }

    return (
      <div className="flex flex-col">
        <h2 className="text-l font-bold text-black mb-5">Constructed With</h2>
        <div className="flex">
          {selectedCreation.voxelTypes.map((voxelType, idx) => {
            const iconKey = voxelTypeDataKeyToVoxelVariantDataKey(voxelType);
            const iconUrl = getVoxelIconUrl(iconKey);
            return (
              <div key={"creation-voxel-" + idx} className="bg-slate-100 p-1 w-fit">
                <img src={iconUrl} />
              </div>
            );
          })}
        </div>
      </div>
    );
  };

  if (selectedCreation === null) {
    return null;
  }

  return (
    <div className="flex flex-col h-full mt-5 gap-5">
      <h4 className="text-2xl font-bold text-black">{selectedCreation.name}</h4>
      <p className="font-normal text-gray-700 leading-4">{selectedCreation.description}</p>
      <p className="font-normal text-gray-700 leading-4">
        <b>Creator:</b> {selectedCreation.creator}
      </p>
      <p className="font-normal text-gray-700 leading-4">
        <b># Spawns:</b> {selectedCreation.numSpawns.toString()}
      </p>
      {renderVoxelTypes()}
    </div>
  );
};

export default CreationDetails;
