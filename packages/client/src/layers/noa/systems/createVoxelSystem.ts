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
import { NoaLayer } from "../types";

function removeNullBytes(str){
  return str.split("").filter(char => char.codePointAt(0)).join("")
}

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
    voxelTypes: { VoxelVariantData },
  } = network;

  // Loading state flag
  let live = false;
  awaitStreamValue(
    LoadingState.update$,
    ({ value }) => value[0]?.state === SyncState.LIVE
  ).then(() => (live = true));

  defineComponentSystem(world, VoxelVariants, (update) => {
    console.log("voxel type registry updated");
    console.log(update);
    // TODO: could use update.value?
    const voxelVariantValue = getComponentValueStrict(VoxelVariants, update.entity);
    const [voxelVariantNamespace, voxelVariantId] = update.entity.split(":");
    const voxelVariantNamepaceStr = removeNullBytes(toUtf8String(voxelVariantNamespace));
    const voxelVariantDataKey = {
      voxelVariantNamespace: voxelVariantNamepaceStr,
      voxelVariantId: voxelVariantId
    }
    console.log(voxelVariantDataKey);
    if(!VoxelVariantData.has(voxelVariantDataKey)) {
      console.log("Adding new variant");
      const voxelVariantData = {
        index: voxelVariantValue.variantId,
        data: {
          material: voxelVariantValue.material ? `https://${voxelVariantValue.material}.ipfs.nftstorage.link/`: "",
          type: voxelVariantValue.blockType,
          frames: voxelVariantValue.frames,
          opaque: voxelVariantValue.opaque,
          fluid: voxelVariantValue.fluid,
          solid: voxelVariantValue.solid,
          // TODO: add block mesh
          uvWrap: voxelVariantValue.uvWrap ? `https://${voxelVariantValue.uvWrap}.ipfs.nftstorage.link/`: undefined,
        }
      }
      console.log(voxelVariantData);
      VoxelVariantData.set(voxelVariantDataKey, voxelVariantData);
    }
  });

  defineComponentSystem(world, VoxelType, (update) => {
    console.log("voxel type updated");
    console.log(update);
  });

  // "Exit system"
  defineComponentSystem(world, Position, async ({ value }) => {
    if (!live) return;
    if (!value[0] && value[1]) {
      const voxel = getVoxelAtPosition(value[1]);
      setVoxel(value[1], voxel);
    }
  });

  // "Enter system"
  defineEnterSystem(world, [Has(Position), Has(VoxelType)], (update) => {
    if (!live) return;
    const position = getComponentValueStrict(Position, update.entity);
    const voxel = getVoxelAtPosition(position);
    setVoxel(position, voxel);
  });
}
