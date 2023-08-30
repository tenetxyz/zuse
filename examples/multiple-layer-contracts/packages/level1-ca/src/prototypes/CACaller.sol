// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { buildWorld, mineWorld, moveWorld } from "@tenet-base-ca/src/CallUtils.sol";
import { entityToCAEntity } from "@tenet-base-ca/src/Utils.sol";
import { distanceBetween } from "@tenet-utils/src/VoxelCoordUtils.sol";

abstract contract CACaller is System {
  function buildCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) public virtual {
    buildWorld(callerAddress, voxelTypeId, coord);
  }

  function mineCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) public virtual {
    mineWorld(callerAddress, voxelTypeId, coord);
  }

  function moveCAWorld(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public virtual returns (bytes32, bytes32) {
    // Note: Currently, we only support movements of 1 voxel in any direction
    require(distanceBetween(oldCoord, newCoord) == 1, "Can only move 1 voxel at a time");
    bytes memory returnData = moveWorld(callerAddress, voxelTypeId, oldCoord, newCoord);
    (, bytes32 oldEntityId, bytes32 newEntityId) = abi.decode(returnData, (uint32, bytes32, bytes32));
    return (entityToCAEntity(callerAddress, oldEntityId), entityToCAEntity(callerAddress, newEntityId));
  }
}
