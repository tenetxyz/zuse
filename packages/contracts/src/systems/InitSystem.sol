// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { WorldConfig, WorldConfigTableId, Player, PlayerData } from "@tenet-contracts/src/codegen/Tables.sol";
import { WorldRegistry } from "@tenet-registry/src/codegen/tables/WorldRegistry.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { REGISTER_WORLD_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS, LEVEL_2_CA_ADDRESS, LEVEL_3_CA_ADDRESS } from "../Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract InitSystem is System {
  function registerWorld() public {
    address[] memory caAddresses = new address[](3);
    caAddresses[0] = BASE_CA_ADDRESS;
    caAddresses[1] = LEVEL_2_CA_ADDRESS;
    caAddresses[2] = LEVEL_3_CA_ADDRESS;

    safeCall(
      REGISTRY_ADDRESS,
      abi.encodeWithSignature(REGISTER_WORLD_SIG, "Tenet Base World", "Very fun. Very nice.", caAddresses),
      "registerCA"
    );
  }

  function initWorldVoxelTypes() public {
    // Go through all the CA's
    address[] memory caAddresses = WorldRegistry.getCaAddresses(IStore(REGISTRY_ADDRESS), _world());
    for (uint256 i; i < caAddresses.length; i++) {
      address caAddress = caAddresses[i];
      // Go through all the voxel types
      bytes32[] memory voxelTypeIds = CARegistry.getVoxelTypeIds(IStore(REGISTRY_ADDRESS), caAddress);
      for (uint256 j; j < voxelTypeIds.length; j++) {
        // TODO: Check for duplicates?
        WorldConfig.set(voxelTypeIds[j], caAddress);
      }
    }
  }

  function isCAAllowed(address caAddress) public view returns (bool) {
    address[] memory caAddresses = WorldRegistry.getCaAddresses(IStore(REGISTRY_ADDRESS), _world());
    for (uint256 i = 0; i < caAddresses.length; i++) {
      if (caAddresses[i] == caAddress) {
        return true;
      }
    }
    return false;
  }

  function isVoxelTypeAllowed(bytes32 voxelTypeId) public view returns (bool) {
    return hasKey(WorldConfigTableId, WorldConfig.encodeKeyTuple(voxelTypeId));
  }
}
