import React, { ChangeEvent, KeyboardEvent } from "react";
import { ComponentRecord, Layers } from "../../../types";
import { Entity, getComponentValue, getComponentValueStrict, setComponent } from "@latticexyz/recs";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import { calculateMinMax } from "../../../utils/voxels";
import { useComponentValue } from "@latticexyz/react";
import {
  add,
  decodeCoord,
  getVoxelCoordsOfCreation,
  getWorldScale,
  stringToVoxelCoord,
  sub,
  voxelCoordToString,
} from "../../../utils/coord";
import { FocusedUiType } from "../../noa/components/FocusedUi";
import { twMerge } from "tailwind-merge";
import { SetState } from "../../../utils/types";
import { stringToEntity } from "../../../utils/entity";
import { defineSpawnInFocusComponent } from "../../noa/components";
import { VoxelCoord } from "@latticexyz/utils";

export interface RegisterCreationFormData {
  name: string;
  description: string;
}

export interface BaseCreationInWorld {
  creationId: string;
  lowerSouthWestCornerInWorld: VoxelCoord;
  deletedRelativeCoords: VoxelCoord[]; // these coords are relative to the BASE creation's lowerSouthWestCorner. NOT the new creation we are using this in
}

interface Props {
  layers: Layers;
  formData: RegisterCreationFormData;
  setFormData: SetState<RegisterCreationFormData>;
  resetRegisterCreationForm: () => void;
}

const RegisterCreation: React.FC<Props> = ({ layers, formData, setFormData, resetRegisterCreationForm }) => {
  const {
    noa: {
      components: { VoxelSelection, PersistentNotification, FocusedUi },
      SingletonEntity,
    },
    network: {
      contractComponents: { OfSpawn, Spawn, Position, Creation },
      api: { getEntityAtPosition, registerCreation },
      storeCache,
    },
  } = layers;

  type IVoxelSelection = ComponentRecord<typeof VoxelSelection>;
  const corners: IVoxelSelection | undefined = useComponentValue(VoxelSelection, SingletonEntity);

  const handleSubmit = () => {
    const allVoxels = getVoxelsWithinSelection();
    const { voxelsNotInSpawn, spawnDefs } = separateVoxelsFromSpawns(allVoxels);
    const baseCreationsInWorld = calculateBaseCreationsInWorld(spawnDefs);
    registerCreation(formData.name, formData.description, voxelsNotInSpawn, baseCreationsInWorld);
    resetRegisterCreationForm();
  };
  const separateVoxelsFromSpawns = (voxels: Entity[]) => {
    const spawnDefs = new Set<string>(); // spawnId, and lowerleft corner
    const voxelsNotInSpawn = [];
    for (const voxel of voxels) {
      const spawnId = getComponentValue(OfSpawn, voxel)?.value;
      if (spawnId) {
        const encodedLowerSouthWestCorner = getComponentValueStrict(
          Spawn,
          stringToEntity(spawnId)
        ).lowerSouthWestCorner;
        spawnDefs.add(`${spawnId}:${encodedLowerSouthWestCorner}`);
      } else {
        voxelsNotInSpawn.push(voxel);
      }
    }
    return { voxelsNotInSpawn, spawnDefs };
  };

  const calculateBaseCreationsInWorld = (spawnDefs: Set<string>): BaseCreationInWorld[] => {
    const baseCreations: BaseCreationInWorld[] = [];

    // for each spawn, check to see if all of its voxels are in its defined cooordinate in the base creation.
    // if it is not, then it must be deleted
    for (const spawnDef of spawnDefs) {
      const [spawnId, encodedLowerSouthWestCorner] = spawnDef.split(":");
      const lowerSouthWestCornerInWorld = decodeCoord(encodedLowerSouthWestCorner);

      const spawn = getComponentValueStrict(Spawn, stringToEntity(spawnId));
      const deletedRelativeCoords = findDeletedVoxelCoords(spawn, lowerSouthWestCornerInWorld);

      baseCreations.push({
        creationId: spawn.creationId,
        lowerSouthWestCornerInWorld,
        deletedRelativeCoords,
      });
    }
    return baseCreations;
  };

  // The deleted voxel coords are the ones that are in the creation, but not in the spawn
  // What if you place a spawn, and another spawn overlaps and deletes one block, will this code still work?
  // Yes. Since that block was deleted by the second spawn, it will not show up as a voxel of that spawn, so it will still be flagged as deleted
  const findDeletedVoxelCoords = (spawn: any, lowerSouthWestCornerInWorld: VoxelCoord) => {
    const creationVoxelCoords = getVoxelCoordsOfCreation(Creation, stringToEntity(spawn.creationId));

    const creationVoxelCoordsInWorld = new Set<string>(
      creationVoxelCoords.map((voxelCoord) => add(lowerSouthWestCornerInWorld, voxelCoord)).map(voxelCoordToString)
    ); // convert to string so we can use a set to remove coords that are in the world

    for (const voxel of spawn.voxels) {
      const position = storeCache.tables.Position.get({ entity: stringToEntity(voxel), scale: getWorldScale(noa) });
      const voxelCoordInSpawn = voxelCoordToString(position);
      creationVoxelCoordsInWorld.delete(voxelCoordInSpawn);
    }

    return Array.from(creationVoxelCoordsInWorld)
      .map(stringToVoxelCoord)
      .map((voxelCoord) => sub(voxelCoord, lowerSouthWestCornerInWorld)); // make these voxel coords relative to the lowerSouthWestCornerInWorld (this is what the registerCreationSystem expects)
  };

  const handleInputChange = (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const isSubmitDisabled = !formData.name || !corners?.corner1 || !corners?.corner2;

  //get all voxels within the selected corners
  const getVoxelsWithinSelection = (): Entity[] => {
    const corner1 = corners?.corner1;
    const corner2 = corners?.corner2;
    if (!corner1 || !corner2) return [];
    const { minX, maxX, minY, maxY, minZ, maxZ } = calculateMinMax(corner1, corner2);
    const voxels: Entity[] = [];
    for (let x = minX; x <= maxX; x++) {
      for (let y = minY; y <= maxY; y++) {
        for (let z = minZ; z <= maxZ; z++) {
          const entity = getEntityAtPosition({ x, y, z });
          if (entity !== undefined) {
            voxels.push(entity);
          }
        }
      }
    }
    return voxels;
  };

  const onSelectCreationCorners = () => {
    setComponent(PersistentNotification, SingletonEntity, {
      message:
        "Select your creation's corners by 1) Holding 'V' and 2) Left/Right clicking on blocks. Press - when done.",
      icon: NotificationIcon.NONE,
    });
    setComponent(FocusedUi, SingletonEntity, { value: FocusedUiType.WORLD });
  };

  const selectCreationCornerButtonLabel =
    corners?.corner1 && corners?.corner2 ? (
      <>
        <p>Change Creation Corners</p>
        <p className="mt-2">
          {voxelCoordToString(corners.corner1)} {voxelCoordToString(corners.corner2)}
        </p>
      </>
    ) : corners?.corner1 || corners?.corner2 ? (
      "Please select both corners"
    ) : (
      "Select Creation Corners"
    );

  return (
    <div className="flex flex-col gap-y-4 mt-5">
      <h4 className="text-2xl font-bold text-black">Register New Creation</h4>
      <div>
        <label className="block mb-2 text-sm font-medium text-gray-900">Creation Name</label>
        <input
          type="text"
          placeholder="ABC"
          value={formData.name}
          onChange={handleInputChange}
          autoComplete={"on"}
          name="name"
          className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
        />
      </div>
      <div>
        <label className="block mb-2 text-sm font-medium text-gray-900">Description (optional)</label>
        <input
          type="text"
          placeholder=""
          value={formData.description}
          onChange={handleInputChange}
          name="description"
          className="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
        />
      </div>
      <button
        type="button"
        onClick={onSelectCreationCorners}
        className="py-2.5 px-5 mr-2 mb-2 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-200"
      >
        {selectCreationCornerButtonLabel}
      </button>
      <button
        onClick={handleSubmit}
        disabled={isSubmitDisabled}
        className={twMerge(
          "text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center",
          isSubmitDisabled ? "opacity-50 cursor-not-allowed" : ""
        )}
      >
        Submit
      </button>
    </div>
  );
};

export default RegisterCreation;
