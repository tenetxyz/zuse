// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CACaller } from "@tenet-base-ca/src/prototypes/CACaller.sol";

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
}
