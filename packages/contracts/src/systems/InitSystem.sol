// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelTypesAllowed } from "@tenet-contracts/src/codegen/Tables.sol";
import { WorldRegistry } from "@tenet-registry/src/codegen/tables/WorldRegistry.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { REGISTER_WORLD_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS } from "../Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract InitSystem is System {
  function registerWorld() public {
    address[] memory caAddresses = new address[](1);
    caAddresses[0] = BASE_CA_ADDRESS;

    safeCall(
      REGISTRY_ADDRESS,
      abi.encodeWithSignature(REGISTER_WORLD_SIG, "Tenet Base World", "Very fun. Very nice.", caAddresses),
      "registerCA"
    );
  }

  function initWorldVoxelTypes() public {
    // Go through all the CA's
    address[] memory caAddresses = WorldRegistry.getCaAddresses(_world());
    for (uint256 i; i < caAddresses.length; i++) {
      address caAddress = caAddresses[i];
      // Go through all the voxel types
      bytes32[] memory voxelTypeIds = CARegistry.getVoxelTypeIds(caAddress);
      for (uint256 j; j < voxelTypeIds.length; j++) {
        // TODO: Check for duplicates?
        VoxelTypesAllowed.push(voxelTypeIds[j]);
      }
    }
  }

  function isCAAllowed(address caAddress) public view returns (bool) {
    address[] memory caAddresses = WorldRegistry.getCaAddresses(_world());
    for (uint256 i = 0; i < caAddresses.length; i++) {
      if (caAddresses[i] == caAddress) {
        return true;
      }
    }
    return false;
  }

  function isVoxelTypeAllowed(bytes32 voxelTypeId) public view returns (bool) {
    bytes32[] memory allVoxelTypeIds = VoxelTypesAllowed.get();
    for (uint256 i = 0; i < allVoxelTypeIds.length; i++) {
      if (allVoxelTypeIds[i] == voxelTypeId) {
        return true;
      }
    }
    return false;
  }
}
