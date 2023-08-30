import React from "react";
import { Layers } from "../../../types";
import { Entity, getComponentValueStrict } from "@latticexyz/recs";
import { voxelCoordToString } from "../../../utils/coord";
import { Separator } from "@radix-ui/react-dropdown-menu";
import { Creation } from "@/mud/componentParsers/creation";
import { Slot } from "./common";
import { VoxelTypeKey } from "@/layers/noa/types";

interface Props {
  layers: Layers;
  selectedCreation: Creation | null;
}

const CreationDetails: React.FC<Props> = ({ layers, selectedCreation }: Props) => {
  const {
    network: {
      getVoxelIconUrl,
      parsedComponents: { ParsedCreationRegistry, ParsedVoxelTypeRegistry },
    },
  } = layers;
  if (selectedCreation === null) {
    return null;
  }

  interface VoxelCount {
    voxelTypeKey: VoxelTypeKey;
    count: number;
  }

  const renderVoxelTypes = () => {
    const uniqueVoxelTypesWithCount = selectedCreation.voxelTypes.reduce(
      (acc: VoxelCount[], voxelTypeKey: VoxelTypeKey) => {
        // Find the existing unique object in the accumulator array
        const found = acc.find((item) => item.voxelTypeKey.voxelVariantTypeId === voxelTypeKey.voxelVariantTypeId);

        if (found) {
          // Increment the count of the existing unique object
          found.count += 1;
        } else {
          // Add a new unique object with a count of 1
          acc.push({ voxelTypeKey, count: 1 });
        }

        return acc;
      },
      []
    );

    return (
      <div className="flex flex-col">
        <h2 className="text-l font-bold mb-5">Constructed With:</h2>
        <div className="flex">
          {uniqueVoxelTypesWithCount.map(({ voxelTypeKey, count }, idx) => {
            const iconUrl = getVoxelIconUrl(voxelTypeKey.voxelVariantTypeId);
            const voxelTypeDesc = ParsedVoxelTypeRegistry.getRecordStrict(voxelTypeKey.voxelBaseTypeId as Entity);
            return (
              <div key={"creation-voxel-" + idx} className="p-1 w-fit border rounded border-slate-700">
                <Slot
                  voxelType={voxelTypeKey.voxelBaseTypeId as Entity}
                  iconUrl={iconUrl}
                  slotSize={64}
                  quantity={count}
                  tooltipText={<p>{voxelTypeDesc.name}</p>}
                />
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
            const childCreation = ParsedCreationRegistry.componentRows.get(baseCreation.creationId);
            return (
              <div key={"creation-base-creation-" + idx} className="text-slate-700 p-1 w-fit">
                {childCreation?.name} at {voxelCoordToString(baseCreation.coordOffset)}
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