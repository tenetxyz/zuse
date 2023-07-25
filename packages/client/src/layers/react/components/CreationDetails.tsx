import React from "react";
import { Layers } from "../../../types";
import { Creation } from "./CreationStore";
import { getComponentValueStrict } from "@latticexyz/recs";
import { voxelCoordToString } from "../../../utils/coord";

interface Props {
  layers: Layers;
  selectedCreation: Creation | null;
}

const CreationDetails: React.FC<Props> = ({ layers, selectedCreation }: Props) => {
  const {
    network: {
      getVoxelIconUrl,
      contractComponents: { Creation },
    },
  } = layers;
  if (selectedCreation === null) {
    return null;
  }

  const renderVoxelTypes = () => {
    return (
      <div className="flex flex-col">
        <h2 className="text-l font-bold text-black mb-5">Constructed With</h2>
        <div className="flex">
          {selectedCreation.voxelTypes.map((voxelType, idx) => {
            const iconUrl = getVoxelIconUrl(voxelType.voxelVariantTypeId);
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

  const renderBaseCreations = () => {
    return (
      <div className="flex flex-col">
        <h2 className="text-l font-bold text-black mb-5">Base Creations</h2>
        <div className="flex">
          {selectedCreation.baseCreations.map((baseCreation, idx) => {
            const childCreation = getComponentValueStrict(Creation, baseCreation.creationId);
            return (
              <div key={"creation-base-creation-" + idx} className="text-slate-700 p-1 w-fit">
                {childCreation.name} at {voxelCoordToString(baseCreation.coordOffset)}
              </div>
            );
          })}
        </div>
      </div>
    );
  };

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
      {renderBaseCreations()}
    </div>
  );
};

export default CreationDetails;
