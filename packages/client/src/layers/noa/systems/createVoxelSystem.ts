import { SyncState } from "@latticexyz/network";
import {
  defineComponentSystem,
  defineEnterSystem,
  getComponentValueStrict,
  Has,
} from "@latticexyz/recs";
import { toUtf8String } from "ethers/lib/utils.js";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaLayer, voxelVariantDataKeyToString, VoxelVariantDataValue } from "../types";
import { NoaVoxelDef } from "../types";
import { formatNamespace } from "../../../constants";
import { getNftStorageLink } from "../constants";

export async function createVoxelSystem(
  network: NetworkLayer,
  context: NoaLayer
) {
  const {
    api: { setVoxel },
  } = context;

  const {
    world,
    components: { LoadingState },
    contractComponents: { VoxelType, Position, VoxelVariants },
    actions: { withOptimisticUpdates },
    api: { getVoxelAtPosition },
    voxelTypes: { VoxelVariantData, VoxelVariantDataSubscriptions },
  } = network;

  // Loading state flag
  let live = false;
  awaitStreamValue(
    LoadingState.update$,
    ({ value }) => value[0]?.state === SyncState.LIVE
  ).then(() => (live = true));

  defineComponentSystem(world, VoxelVariants, (update) => {
    console.log("Voxel type registry updated");
    console.log(update);
    // TODO: could use update.value?
    const voxelVariantValue = getComponentValueStrict(VoxelVariants, update.entity);
    const [voxelVariantNamespace, voxelVariantId] = update.entity.split(":");
    const voxelVariantDataKey = {
      voxelVariantNamespace: formatNamespace(voxelVariantNamespace),
      voxelVariantId: voxelVariantId
    }

    if(!VoxelVariantData.has(voxelVariantDataKeyToString(voxelVariantDataKey))) {
      console.log("Adding new variant");
      const materialArr = voxelVariantValue.materialArr.split("|");
      // go through each hash in materialArr and format it to have the NFT storage link
      const formattedMaterialArr: string[] = materialArr.map((hash: string) => {
        return getNftStorageLink(hash);
      });
      let material: string | string[] = "";
      if(formattedMaterialArr.length == 1){
        material = formattedMaterialArr[0];
      } else {
        material = formattedMaterialArr;
      }

      const voxelVariantData: VoxelVariantDataValue = {
        index: Number(voxelVariantValue.variantId),
        data: {
            material: material as any, // TODO: replace any with proper string[]
            type: voxelVariantValue.blockType,
            frames: voxelVariantValue.frames,
            opaque: voxelVariantValue.opaque,
            fluid: voxelVariantValue.fluid,
            solid: voxelVariantValue.solid,
            // TODO: add block mesh
            uvWrap: voxelVariantValue.uvWrap ? getNftStorageLink(voxelVariantValue.uvWrap): undefined,
          }
        }
        VoxelVariantData.set(voxelVariantDataKeyToString(voxelVariantDataKey), voxelVariantData);
        VoxelVariantDataSubscriptions.forEach((subscription) => {
          subscription(voxelVariantDataKey, voxelVariantData);
        });
      } else {
        console.log("Variant already exists");
      }
    }
  );

  // "Exit system"
  defineComponentSystem(world, Position, async ({ value }) => {
    if (!live) return;
    if (!value[0] && value[1]) {
      const voxel = getVoxelAtPosition(value[1]);
      setVoxel(value[1], {
        voxelVariantNamespace: voxel.voxelVariantNamespace,
        voxelVariantId: voxel.voxelVariantId,
      });
    }
  });

  // "Enter system"
  defineEnterSystem(world, [Has(Position), Has(VoxelType)], (update) => {
    if (!live) return;
    const position = getComponentValueStrict(Position, update.entity);
    const voxel = getVoxelAtPosition(position);
    setVoxel(position, {
      voxelVariantNamespace: voxel.voxelVariantNamespace,
      voxelVariantId: voxel.voxelVariantId,
    });
  });
}
