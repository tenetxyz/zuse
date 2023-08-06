// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { CAVoxelConfig, CAVoxelConfigTableId } from "@tenet-base-ca/src/codegen/tables/CAVoxelConfig.sol";
import { ADD_VOXEL_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

abstract contract CAVoxelRegistry is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function registerVoxelType(
    bytes32 voxelTypeId,
    bytes4 enterWorldSelector,
    bytes4 exitWorldSelector,
    bytes4 voxelVariantSelector,
    bytes4 activateSelector,
    bytes4 interactionSelector
  ) public virtual {
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
    safeCall(getRegistryAddress(), abi.encodeWithSignature(ADD_VOXEL_CA_SIG, voxelTypeId), "addVoxelToCA");
  }
}
