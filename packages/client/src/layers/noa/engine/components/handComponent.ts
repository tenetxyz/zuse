import * as BABYLON from "@babylonjs/core";
import { Engine } from "noa-engine";
import { Entity } from "@latticexyz/recs";
import { Material } from "@babylonjs/core";
import { VoxelTypeIdToKey, VoxelTypeKey } from "../../../network/constants";
import {
  IDLE_ANIMATION_BOX_VOXEL,
  IDLE_ANIMATION_BOX_HAND,
  MINING_ANIMATION_BOX_VOXEL,
  MINING_ANIMATION_BOX_HAND,
} from "../hand";

export interface HandComponent {
  isMining: boolean;
  handMesh: BABYLON.Mesh;
  voxelMesh: BABYLON.Mesh;
  voxelMaterials: { [key in VoxelTypeKey]?: Material };
  __id: number;
}

export const HAND_COMPONENT = "HAND_COMPONENT";

export function registerHandComponent(
  noa: Engine,
  getSelectedVoxelType: () => Entity | undefined
) {
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  //@ts-ignore
  noa.ents.createComponent({
    name: HAND_COMPONENT,
    state: {
      isMining: false,
      handMesh: null,
      voxelMesh: null,
      voxelMaterial: null,
    },
    system: function (dt: number, states: HandComponent[]) {
      for (let i = 0; i < states.length; i++) {
        const { handMesh, isMining, voxelMesh, voxelMaterials } = states[i];
        const id = states[i].__id;
        if (id === noa.playerEntity) {
          // NOTE: for now just animate / change the material of the player hand
          const selectedVoxelType = getSelectedVoxelType();
          const voxelTypeKey =
            selectedVoxelType && VoxelTypeIdToKey[selectedVoxelType];
          if (voxelTypeKey && voxelMaterials[voxelTypeKey] !== undefined) {
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            voxelMesh.material = voxelMaterials[voxelTypeKey]!;
            handMesh.visibility = 0;
            voxelMesh.visibility = 1;
          } else {
            handMesh.visibility = 1;
            voxelMesh.visibility = 0;
          }
          if (isMining && handMesh.animations[0].name.includes("idle")) {
            handMesh.animations.pop();
            handMesh.animations.push(MINING_ANIMATION_BOX_HAND);
            voxelMesh.animations.pop();
            voxelMesh.animations.push(MINING_ANIMATION_BOX_VOXEL);
            const scene = noa.rendering.getScene();
            scene.stopAnimation(handMesh);
            scene.stopAnimation(voxelMesh);
            scene.beginAnimation(handMesh, 0, 100, true);
            scene.beginAnimation(voxelMesh, 0, 100, true);
          } else if (
            !isMining &&
            handMesh.animations[0].name.includes("mining")
          ) {
            handMesh.animations.pop();
            handMesh.animations.push(IDLE_ANIMATION_BOX_HAND);
            voxelMesh.animations.pop();
            voxelMesh.animations.push(IDLE_ANIMATION_BOX_VOXEL);
            const scene = noa.rendering.getScene();
            scene.stopAnimation(handMesh);
            scene.stopAnimation(voxelMesh);
            scene.beginAnimation(handMesh, 0, 100, true);
            scene.beginAnimation(voxelMesh, 0, 100, true);
          }
        }
      }
    },
  });
}
