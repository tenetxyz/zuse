import React, { useState, ChangeEvent, KeyboardEvent } from "react";
import { Layers } from "../../../types";
import { setComponent } from "../../../../../../../mud/packages/recs";
import { NotificationIcon } from "../../noa/components/persistentNotification";
import { IVoxelSelection } from "../../noa/components/VoxelSelection";
import { VoxelCoord } from "@latticexyz/utils";

interface CreationFormData {
  name: string;
  description: string;
}

interface CreationCorners {
  topLeft: string;
  bottomRight: string;
}

interface Props {
  layers: Layers;
}
interface CreationCorners {
  corner1: VoxelCoord | undefined;
  corner2: VoxelCoord | undefined;
}

const RegisterCreation: React.FC<Props> = ({ layers }) => {
  const {
    noa: {
      components: { VoxelSelection, PersistentNotification },
      SingletonEntity,
      api: {
        toggleInventory,
      }
    },

  } = layers;
  const [formData, setFormData] = useState<CreationFormData>({
    name: "",
    description: "",
  });

  const [corners, setCorners] = useState<CreationCorners>({
    corner1: undefined,
    corner2: undefined,
  } as CreationCorners);

  const handleSubmit = () => {
    getCreationEntities();
    // TODO: call submit creation system
    resetForm();
  };
  const getCreationEntities = () => {};

  const resetForm = () => {
    setFormData({ name: "", description: "" });
    setComponent(VoxelSelection, SingletonEntity, {
      points: undefined,
      corner1: undefined,
      corner2: undefined,
    } as any);
  };

  const handleInputChange = (
    e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const trySubmitCreation = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      handleSubmit();
    }
  };

  React.useEffect(() => {
    VoxelSelection.update$.subscribe((update) => {
      const voxelSelection = update.value[0] as IVoxelSelection;
      setCorners({
        corner1: voxelSelection.corner1,
        corner2: voxelSelection.corner2,
      } as CreationCorners);
    });
  }, []);

  const onSelectCreationCorners = () => {
    setComponent(PersistentNotification, SingletonEntity, {
      message:
        "Select your creation's corners by 1) Holding 'V' and 2) Left/Right clicking on blocks",
      icon: NotificationIcon.NONE,
    });
    toggleInventory();
  };

  const isSubmitDisabled =
    !formData.name ||
    !formData.description ||
    !corners.corner1 ||
    !corners.corner2;

  return (
    <div className="max-w-md mx-auto p-4 text-slate-700" onKeyDown={trySubmitCreation}>
      <input
        className="border rounded px-2 py-1 mb-2 w-full"
        type="text"
        placeholder="Enter creation name"
        name="name"
        value={formData.name}
        onChange={handleInputChange}
      />
      <textarea
        className="border rounded px-2 py-1 mb-2 w-full"
        placeholder="Enter creation description"
        name="description"
        value={formData.description}
        onChange={handleInputChange}
      />
      <button
        className="border rounded px-2 py-1 mb-2 w-full"
        onClick={onSelectCreationCorners}
      >
        "Select Creation Corners"
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
