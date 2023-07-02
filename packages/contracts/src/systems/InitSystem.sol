// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { defineVoxels, AirID, DirtID, GrassID, BedrockID } from "../prototypes/Voxels.sol";
import { VoxelVariantsKey } from "../Types.sol";
import { TENET_NAMESPACE } from "../Constants.sol";

contract InitSystem is System {
  function airVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: AirID });
  }

  function dirtVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: DirtID });
  }

  function grassVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: GrassID });
  }

  function bedrockVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: BedrockID });
  }

  function init() public {
    defineVoxels(IWorld(_world()));
  }
}
