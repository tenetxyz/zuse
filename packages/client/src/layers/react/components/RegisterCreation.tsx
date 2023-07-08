import React, { ChangeEvent, KeyboardEvent } from "react";
import { ComponentRecord, Layers } from "../../../types";
import { Entity, setComponent } from "@latticexyz/recs";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import { calculateMinMax } from "../../../utils/voxels";
import { useComponentValue } from "@latticexyz/react";
import { voxelCoordToString } from "../../../utils/coord";
import { FocusedUiType } from "../../noa/components/FocusedUi";

export interface RegisterCreationFormData {
  name: string;
  description: string;
}

interface Props {
  layers: Layers;
  formData: RegisterCreationFormData;
  setFormData: React.Dispatch<React.SetStateAction<RegisterCreationFormData>>;
}

const RegisterCreation: React.FC<Props> = ({ layers, formData, setFormData }) => {
  const {
    noa: {
      components: { VoxelSelection, PersistentNotification, FocusedUi },
      SingletonEntity,
    },
    network: {
      api: { getEntityAtPosition, registerCreation },
    },
  } = layers;

  type IVoxelSelection = ComponentRecord<typeof VoxelSelection>;
  const corners: IVoxelSelection | undefined = useComponentValue(VoxelSelection, SingletonEntity);

  const handleSubmit = () => {
    const voxels = getVoxelsWithinSelection();
    registerCreation(formData.name, formData.description, voxels);
    resetForm();
  };

  const resetForm = () => {
    setFormData({ name: "", description: "" });
    setComponent(VoxelSelection, SingletonEntity, {
      corner1: undefined,
      corner2: undefined,
    } as any);
  };

  const handleInputChange = (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const isSubmitDisabled = !formData.name || !corners?.corner1 || !corners?.corner2;

  const trySubmitCreation = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter" && !isSubmitDisabled) {
      handleSubmit();
    }
  };

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
        "Select your creation's corners by 1) Holding 'V' and 2) Left/Right clicking on blocks. Press e when done.",
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
    <div className="max-w-md mx-auto p-4 text-slate-700" onKeyDown={trySubmitCreation}>
      <input
        className="border rounded px-2 py-1 mb-2 w-full"
        type="text"
        placeholder="Enter creation name"
        name="name"
        value={formData.name}
        onChange={handleInputChange}
        autoComplete={"on"}
      />
      <textarea
        className="border rounded px-2 py-1 mb-2 w-full"
        placeholder="Description (optional)"
        name="description"
        value={formData.description}
        onChange={handleInputChange}
      />
      <button
        className={`rounded px-2 py-1 mb-2 w-full bg-zinc-500 text-white hover:bg-zinc-400 p-5`}
        onClick={onSelectCreationCorners}
      >
        {selectCreationCornerButtonLabel}
      </button>
      <button
        className={`bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 mb-2 ${
          isSubmitDisabled ? "opacity-50 cursor-not-allowed" : ""
        }`}
        onClick={handleSubmit}
        disabled={isSubmitDisabled}
      >
        Submit
      </button>
    </div>
  );
};

export default RegisterCreation;
