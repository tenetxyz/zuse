import { SyncState } from "@latticexyz/network";
import { defineComponentSystem, defineEnterSystem, getComponentValueStrict, Has } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { NetworkLayer } from "../../network";
import { NoaLayer, voxelVariantDataKeyToString, VoxelVariantDataValue } from "../types";
import { NoaVoxelDef } from "../types";
import { formatNamespace } from "../../../constants";
import { getNftStorageLink } from "../constants";
import { abiDecode } from "../../../utils/abi";

export async function createVoxelVariantSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    world,
    components: { LoadingState },
    registryComponents: { VoxelVariantsRegistry },
    voxelTypes: { VoxelVariantData, VoxelVariantDataSubscriptions },
  } = network;

  // Loading state flag
  let live = false;
  awaitStreamValue(LoadingState.update$, ({ value }) => value[0]?.state === SyncState.LIVE).then(() => (live = true));

  defineComponentSystem(world, VoxelVariantsRegistry, (update) => {
    // TODO: could use update.value?
    const voxelVariantValue = getComponentValueStrict(VoxelVariantsRegistry, update.entity);
    const [voxelVariantNamespace, voxelVariantId] = update.entity.split(":");
    const voxelVariantDataKey = {
      voxelVariantNamespace: formatNamespace(voxelVariantNamespace),
      voxelVariantId: voxelVariantId,
    };

    if (!VoxelVariantData.has(voxelVariantDataKeyToString(voxelVariantDataKey))) {
      console.log("Adding new variant");
      debugger;
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
          uvWrap: voxelVariantValue.uvWrap ? getNftStorageLink(voxelVariantValue.uvWrap) : undefined,
        },
      };
      VoxelVariantData.set(voxelVariantDataKeyToString(voxelVariantDataKey), voxelVariantData);
      VoxelVariantDataSubscriptions.forEach((subscription) => {
        subscription(voxelVariantDataKey, voxelVariantData);
      });
    }
  });
}
