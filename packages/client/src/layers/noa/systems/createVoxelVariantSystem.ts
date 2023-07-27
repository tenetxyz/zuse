import { SyncState } from "@latticexyz/network";
import { defineComponentSystem, defineEnterSystem, getComponentValueStrict, Has } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaLayer, VoxelVariantNoaDef } from "../types";
import { getNftStorageLink } from "../constants";
import { abiDecode } from "../../../utils/abi";

export async function createVoxelVariantSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    world,
    components: { LoadingState },
    registryComponents: { VoxelVariantsRegistry },
    voxelTypes: { VoxelVariantIdToDef, VoxelVariantSubscriptions },
  } = network;

  // Loading state flag
  let live = false;
  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(() => (live = true));

  defineComponentSystem(world, VoxelVariantsRegistry, (update) => {
    // TODO: could use update.value?
    const voxelVariantValue = getComponentValueStrict(VoxelVariantsRegistry, update.entity);
    const voxelVariantId = update.entity;

    if (!VoxelVariantIdToDef.has(voxelVariantId)) {
      // console.log("Adding new variant");
      const materialArr: string[] = (abiDecode("string[]", voxelVariantValue.materials, false) as string[]) ?? [];
      // go through each hash in materialArr and format it to have the NFT storage link
      const formattedMaterialArr: string[] = materialArr.map((hash: string) => {
        return getNftStorageLink(hash);
      });
      let material: string | string[] = "";
      if (formattedMaterialArr.length === 1) {
        material = formattedMaterialArr[0];
      } else if (formattedMaterialArr.length > 1) {
        material = formattedMaterialArr;
      }

      const voxelVariantNoaDef: VoxelVariantNoaDef = {
        noaBlockIdx: Number(voxelVariantValue.variantId), // TODO: BUG: When we have over 255 entities, noa will not be able to register this variantId as a block
        noaVoxelDef: {
          material: material as any, // TODO: replace any with proper string[]
          type: voxelVariantValue.blockType,
          frames: voxelVariantValue.frames,
          opaque: voxelVariantValue.opaque,
          fluid: voxelVariantValue.fluid,
          solid: voxelVariantValue.solid,
          // TODO: add block mesh
          uvWrap: voxelVariantValue.uvWrap ? getNftStorageLink(voxelVariantValue.uvWrap) : undefined,
        },
      };
      VoxelVariantIdToDef.set(voxelVariantId, voxelVariantNoaDef);
      VoxelVariantSubscriptions.forEach((subscription) => {
        subscription(voxelVariantId, voxelVariantNoaDef);
      });
    }
  });
}
