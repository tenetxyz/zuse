// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { WorldConfig, WorldConfigTableId } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { WorldRegistry } from "@tenet-registry/src/codegen/tables/WorldRegistry.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { REGISTER_WORLD_SIG } from "@tenet-registry/src/Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

abstract contract InitWorldSystem is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function initWorldVoxelTypes() public virtual {
    // Go through all the CA's
    address[] memory caAddresses = WorldRegistry.getCaAddresses(IStore(getRegistryAddress()), _world());
    for (uint256 i; i < caAddresses.length; i++) {
      address caAddress = caAddresses[i];
      // Go through all the voxel types
      bytes32[] memory voxelTypeIds = CARegistry.getVoxelTypeIds(IStore(getRegistryAddress()), caAddress);
      for (uint256 j; j < voxelTypeIds.length; j++) {
        // TODO: Check for duplicates?
        WorldConfig.set(voxelTypeIds[j], caAddress);
      }
    }
  }

  function onNewCAVoxelType(address caAddress, bytes32 voxelTypeId) public virtual {
    require(_msgSender() == getRegistryAddress(), "Only the registry can call this function");
    require(
      !hasKey(WorldConfigTableId, WorldConfig.encodeKeyTuple(voxelTypeId)),
      "Voxel type already exists in this world"
    );
    require(isCAAllowed(caAddress), "CA is not allowed in this world");
    WorldConfig.set(voxelTypeId, caAddress);
  }

  function isCAAllowed(address caAddress) public view virtual returns (bool) {
    address[] memory caAddresses = WorldRegistry.getCaAddresses(IStore(getRegistryAddress()), _world());
    for (uint256 i = 0; i < caAddresses.length; i++) {
      if (caAddresses[i] == caAddress) {
        return true;
      }
    }
    return false;
  }

  function isVoxelTypeAllowed(bytes32 voxelTypeId) public view virtual returns (bool) {
    return hasKey(WorldConfigTableId, WorldConfig.encodeKeyTuple(voxelTypeId));
  }
}
