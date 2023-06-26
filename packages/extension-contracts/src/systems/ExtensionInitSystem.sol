// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { VoxelVariantsKey } from "../types.sol";
import { defineVoxels, SandID, LogID, OrangeFlowerID } from "../prototypes/Voxels.sol";
import { TENET_NAMESPACE } from "@tenetxyz/contracts/src/constants.sol";

contract ExtensionInitSystem is System {
  function sandVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ namespace: TENET_NAMESPACE, voxelVariantId: SandID });
  }

  function logVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ namespace: TENET_NAMESPACE, voxelVariantId: LogID });
  }

  function orangeFlowerVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ namespace: TENET_NAMESPACE, voxelVariantId: OrangeFlowerID });
  }

  function init() public {
    defineVoxels(_world());
  }
}
