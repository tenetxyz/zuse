import React from "react";
import { Layers } from "../../../types";
import { Creation } from "./CreationStore";
import { getComponentValueStrict } from "@latticexyz/recs";
import { voxelCoordToString } from "../../../utils/coord";
import { Separator } from "@radix-ui/react-dropdown-menu";

interface Props {
  layers: Layers;
  selectedCreation: Creation | null;
}

const CreationDetails: React.FC<Props> = ({ layers, selectedCreation }: Props) => {
  const {
    network: {
      getVoxelIconUrl,
      registryComponents: { CreationRegistry },
    },
  } = layers;
  if (selectedCreation === null) {
    return null;
  }

  const renderVoxelTypes = () => {
    const uniqueVoxelTypes = selectedCreation.voxelTypes.filter(
      (voxelType, index, self) => index === self.findIndex((t) => t.voxelVariantTypeId === voxelType.voxelVariantTypeId)
    );
    return (
      <div className="flex flex-col">
        <h2 className="text-l font-bold mb-5">Constructed With:</h2>
        <div className="flex">
          {uniqueVoxelTypes.map((voxelType, idx) => {
            const iconUrl = getVoxelIconUrl(voxelType.voxelVariantTypeId);
            return (
              <div key={"creation-voxel-" + idx} className="p-1 w-fit border rounded border-slate-700">
                <img src={iconUrl} className="w-[32px] h-[32px]" />
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
        <h2 className="text-l font-bold mb-5">Base Creations:</h2>
        <div className="flex">
          {selectedCreation.baseCreations.map((baseCreation, idx) => {
            const childCreation = getComponentValueStrict(CreationRegistry, baseCreation.creationId);
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
      <h4 className="text-2xl font-bold">{selectedCreation.name}</h4>
      <p className="font-normal text-slate-200 leading-4">{selectedCreation.description}</p>
      <span className="inline-block text-slate-200 text-sm">
        <b>Creator:</b> {selectedCreation.creator.slice(2, 10)}...
      </span>
      <span className="inline-block text-sm text-slate-200">
        <b>Spawns: </b> {selectedCreation.numSpawns.toString()}
      </span>
      <hr className="my-1 border border-slate-600" />
      {renderVoxelTypes()}
      {renderBaseCreations()}
    </div>
  );
};

export default CreationDetails;
