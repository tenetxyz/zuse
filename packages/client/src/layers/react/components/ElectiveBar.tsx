import { useEffect } from "react";
import { ComponentRecord, Layers } from "../../../types";
import { Entity, getComponentValue, getEntityString, setComponent } from "@latticexyz/recs";
import { useComponentValue } from "@latticexyz/react";
import { stringToEntity } from "../../../utils/entity";
import { abiDecode } from "../../../utils/abi";

interface Props {
  layers: Layers;
}
// Shows actions that the player can do based on what voxel they're looking at
export const ElectiveBar = ({ layers }: Props) => {
  const {
    noa: {
      noa,
      components: { SpawnInFocus },
      SingletonEntity,
    },
    network: {
      contractComponents: { OfSpawn, Spawn },
      api: { getEntityAtPosition },
    },
  } = layers;

  // Note: this is only a subset of the actual targetedBlock interface
  interface TargetedBlock {
    position: number[];
  }

  const getTargetedSpawnId = (targetedBlock: TargetedBlock): String | undefined => {
    if (!targetedBlock) {
      return undefined;
    }
    const position = targetedBlock.position;
    // if this block is a spawn, then get the spawnId
    const entityAtPosition = getEntityAtPosition({ x: position[0], y: position[1], z: position[2] });
    if (!entityAtPosition) {
      return undefined;
    }
    return getComponentValue(OfSpawn, entityAtPosition)?.value;
  };

  useEffect(() => {
    noa.on("targetBlockChanged", (targetedBlock: TargetedBlock) => {
      const spawnId = getTargetedSpawnId(targetedBlock);
      if (spawnId) {
        const rawSpawn = getComponentValue(Spawn, stringToEntity(spawnId));
        if (!rawSpawn) {
          console.error("cannot find spawn object with spawnId=", spawnId);
          return;
        }
        // const spawn = {
        //   creationId: stringToEntity(rawSpawn.creationId),
        //   lowerSouthWestCorner: rawSpawn.lowerSouthWestCorner,
        //   voxels: abiDecode("string[]", rawSpawn.voxels) as string[],
        //   interfaceVoxels: rawSpawn.interfaceVoxels,
        // } as Spawn;
        // setComponent(SpawnInFocus, SingletonEntity, { value: spawn });
      } else {
        setComponent(SpawnInFocus, SingletonEntity, { value: undefined });
      }
    });
  }, []);
  const spawnInFocus = useComponentValue(SpawnInFocus, SingletonEntity);
  return <div>{spawnInFocus?.value}</div>;
};
