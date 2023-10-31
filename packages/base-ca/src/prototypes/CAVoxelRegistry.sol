// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ADD_VOXEL_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { callOrRevert } from "@tenet-utils/src/CallUtils.sol";

abstract contract CAVoxelRegistry is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function registerVoxelType(bytes32 voxelTypeId) public virtual {
    // Update registry
    callOrRevert(getRegistryAddress(), abi.encodeWithSignature(ADD_VOXEL_CA_SIG, voxelTypeId), "addVoxelToCA");
  }
}
