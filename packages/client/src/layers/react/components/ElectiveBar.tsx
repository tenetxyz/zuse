import { useEffect } from "react";
import { Layers } from "../../../types";
import { getComponentValue, setComponent } from "@latticexyz/recs";
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

  useEffect(() => {
    noa.on("targetBlockChanged", (targetedBlock: { position: number[] }) => {
      if (!targetedBlock) {
        return;
      }
      const position = targetedBlock.position;
      // if this block is a spawn, then get the spawnId
      const entityAtPosition = getEntityAtPosition({ x: position[0], y: position[1], z: position[3] });
      if (!entityAtPosition) {
        return;
      }
      const spawnId = getComponentValue(OfSpawn, entityAtPosition);
      if (!spawnId) {
        return;
      }
      setComponent(SpawnInFocus, SingletonEntity, { value: entityAtPosition.toString() });
    });
  }, []);
  const spawnInFocus = useComponentValue(SpawnInFocus, SingletonEntity);
  return <div>{spawnInFocus?.value}</div>;
};
