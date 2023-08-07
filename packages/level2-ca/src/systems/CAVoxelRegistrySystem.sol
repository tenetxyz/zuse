// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CAVoxelRegistry } from "@tenet-base-ca/src/prototypes/CAVoxelRegistry.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";

contract CAVoxelRegistrySystem is CAVoxelRegistry {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function registerVoxelType(
    bytes32 voxelTypeId,
    bytes4 enterWorldSelector,
    bytes4 exitWorldSelector,
    bytes4 voxelVariantSelector,
    bytes4 activateSelector,
    bytes4 interactionSelector
  ) public override {
    return
      super.registerVoxelType(
        voxelTypeId,
        enterWorldSelector,
        exitWorldSelector,
        voxelVariantSelector,
        activateSelector,
        interactionSelector
      );
  }
}
