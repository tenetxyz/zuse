// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CACaller } from "../prototypes/CACaller.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

contract CACallerSystem is CACaller {
  function registerInitialVoxelType(
    bytes32 voxelTypeId,
    bytes4 enterWorldSelector,
    bytes4 exitWorldSelector,
    bytes4 voxelVariantSelector,
    bytes4 activateSelector,
    bytes4 interactionSelector
  ) public override {
    return
      super.registerInitialVoxelType(
        voxelTypeId,
        enterWorldSelector,
        exitWorldSelector,
        voxelVariantSelector,
        activateSelector,
        interactionSelector
      );
  }

  function buildCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    return super.buildCAWorld(callerAddress, voxelTypeId, coord);
  }

  function mineCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    return super.mineCAWorld(callerAddress, voxelTypeId, coord);
  }
}
