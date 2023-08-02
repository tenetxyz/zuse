// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { CAVoxelConfig, CAVoxelConfigTableId } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { entityArraysAreEqual } from "@tenet-utils/src/Utils.sol";
import { ADD_VOXEL_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract CAVoxelRegistrySystem is System {
  function registerVoxelType(
    bytes32 voxelTypeId,
    bytes4 enterWorldSelector,
    bytes4 exitWorldSelector,
    bytes4 voxelVariantSelector,
    bytes4 activateSelector,
    bytes4 interactionSelector
  ) public {
    require(
      !hasKey(CAVoxelConfigTableId, CAVoxelConfig.encodeKeyTuple(voxelTypeId)),
      "Voxel type has already been registered for this CA"
    );

    // TODO: Add interface checks on selectors

    CAVoxelConfig.set(
      voxelTypeId,
      enterWorldSelector,
      exitWorldSelector,
      voxelVariantSelector,
      activateSelector,
      interactionSelector
    );

    // Update registry
    safeCall(REGISTRY_ADDRESS, abi.encodeWithSignature(ADD_VOXEL_CA_SIG, voxelTypeId), "addVoxelToCA");
  }
}
