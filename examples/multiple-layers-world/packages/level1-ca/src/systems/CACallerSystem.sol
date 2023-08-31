// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CACaller } from "@tenet-base-ca/src/prototypes/CACaller.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

contract CACallerSystem is CACaller {
  function buildCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    return super.buildCAWorld(callerAddress, voxelTypeId, coord);
  }

  function mineCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    return super.mineCAWorld(callerAddress, voxelTypeId, coord);
  }

  function moveCAWorld(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public override returns (bytes32, bytes32) {
    return super.moveCAWorld(callerAddress, voxelTypeId, oldCoord, newCoord);
  }
}
