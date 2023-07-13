import React, { ChangeEvent, KeyboardEvent } from "react";
import { ComponentRecord, Layers } from "../../../types";
import { Entity, getComponentValue, getComponentValueStrict, setComponent } from "@latticexyz/recs";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import { calculateMinMax } from "../../../utils/voxels";
import { useComponentValue } from "@latticexyz/react";
import { decodeCoord, sub, voxelCoordToString } from "../../../utils/coord";
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

export interface BaseCreation {
  creationId: string;
  lowerSouthWestCornerOfSpawn: VoxelCoord;
  deletedRelativeCoords: VoxelCoord[];
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
      contractComponents: { OfSpawn, Spawn, Position },
      api: { getEntityAtPosition, registerCreation },
    },
  } = layers;

  type IVoxelSelection = ComponentRecord<typeof VoxelSelection>;
  const corners: IVoxelSelection | undefined = useComponentValue(VoxelSelection, SingletonEntity);

  const handleSubmit = () => {
    const allVoxels = getVoxelsWithinSelection();
    const { voxelsNotInSpawn, voxelsInSpawn, spawnDefs } = separateVoxelsFromSpawns(allVoxels);
    const baseCreations = calculateBaseCreations(voxelsInSpawn, spawnDefs);
    registerCreation(formData.name, formData.description, voxelsNotInSpawn, baseCreations);
    resetRegisterCreationForm();
  };
  const separateVoxelsFromSpawns = (voxels: Entity[]) => {
    const spawnDefs = new Set<string>(); // spawnId, and lowerleft corner
    const voxelsNotInSpawn = [];
    const voxelsInSpawn = new Set<string>();
    for (const voxel of voxels) {
      const spawnId = getComponentValue(OfSpawn, voxel)?.value;
      if (spawnId) {
        const encodedLowerSouthWestCorner = getComponentValueStrict(
          Spawn,
          stringToEntity(spawnId)
        ).lowerSouthWestCorner;
        spawnDefs.add(`${spawnId}:${encodedLowerSouthWestCorner}`);
        voxelsInSpawn.add(voxel);
      } else {
        voxelsNotInSpawn.push(voxel);
      }
    }
    return { voxelsNotInSpawn, voxelsInSpawn: voxelsInSpawn, spawnDefs };
  };
  const calculateBaseCreations = (voxelsInSpawn: Set<string>, spawnDefs: Set<string>): BaseCreation[] => {
    const baseCreations: BaseCreation[] = [];
    for (const spawnDef of spawnDefs) {
      const [spawnId, encodedLowerSouthWestCorner] = spawnDef.split(":");
      const lowerSouthWestCornerOfSpawn = decodeCoord(encodedLowerSouthWestCorner);

      const spawn = getComponentValueStrict(Spawn, stringToEntity(spawnId));

      const deletedRelativeCoords = [];
      for (const voxel of spawn.voxels) {
        // if this voxelId doesn't exist in the creation, it must have been deleted
        if (!voxelsInSpawn.has(voxel)) {
          const voxelCoord = getComponentValueStrict(Position, stringToEntity(voxel));
          const relativeCoord = sub(voxelCoord, lowerSouthWestCornerOfSpawn);
          deletedRelativeCoords.push(relativeCoord);
        }
      }
      baseCreations.push({
        creationId: spawn.creationId,
        lowerSouthWestCornerOfSpawn,
        deletedRelativeCoords,
      });
    }
    return baseCreations;
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
