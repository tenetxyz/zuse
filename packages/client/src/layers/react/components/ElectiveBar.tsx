import { useEffect } from "react";
import { ComponentRecord, Layers } from "../../../types";
import { Entity, getComponentValue, getEntityString, setComponent } from "@latticexyz/recs";
import { useComponentValue } from "@latticexyz/react";
import { stringToEntity } from "../../../utils/entity";
import { abiDecode } from "../../../utils/abi";
import { ISpawn } from "../../noa/components/SpawnInFocus";
import { FocusedUiType } from "../../noa/components/FocusedUi";

interface Props {
  layers: Layers;
}
// Shows actions that the player can do based on what voxel they're looking at
export const ElectiveBar = ({ layers }: Props) => {
  const {
    noa: {
      noa,
      components: { SpawnInFocus, SpawnToClassify, FocusedUi },
      SingletonEntity,
    },
    network: {
      contractComponents: { OfSpawn, Spawn, Creation },
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
        const spawn = {
          creationId: stringToEntity(rawSpawn.creationId),
          lowerSouthWestCorner: abiDecode("tuple(int32 x,int32 y,int32 z)", rawSpawn.lowerSouthWestCorner),
          voxels: rawSpawn.voxels as Entity[],
          interfaceVoxels: rawSpawn.interfaceVoxels,
        } as ISpawn;
        const creation = getComponentValue(Creation, spawn.creationId);
        setComponent(SpawnInFocus, SingletonEntity, {
          spawn: spawn,
          creation: creation,
        });
      } else {
        setComponent(SpawnInFocus, SingletonEntity, { spawn: undefined, creation: undefined });
      }
    });
  }, []);
  const spawnInFocus = useComponentValue(SpawnInFocus, SingletonEntity);
  if (!spawnInFocus || spawnInFocus.spawn === undefined) {
    return <></>;
  } else {
    return (
      <div>
        <p>Would you like to classify this spawn of {spawnInFocus?.creation?.name}?</p>
        <button
          onClick={() => {
            setComponent(SpawnToClassify, SingletonEntity, {
              spawn: spawnInFocus.spawn,
              creation: spawnInFocus.creation,
            });
            setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.SIDEBAR });
          }}
        >
          Classify
        </button>
      </div>
    );
  }
};
