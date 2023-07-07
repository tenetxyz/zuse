import { useEffect } from "react";
import { ComponentRecord, Layers } from "../../../types";
import { Entity, getComponentValue, setComponent } from "@latticexyz/recs";
import { useComponentValue } from "@latticexyz/react";

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
      contractComponents: { OfSpawn },
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
      // TODO: get the Spawn corerdpongint o this id
      // also change the component to be the value of htis spawn, not thespawnID
      if (spawnId) {
        setComponent(SpawnInFocus, SingletonEntity, { value: spawnId });
      }
    });
  }, []);
  const spawnInFocus = useComponentValue(SpawnInFocus, SingletonEntity);
  return <div>{spawnInFocus?.value}</div>;
};
