// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CACaller } from "../prototypes/CACaller.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

contract CACallerSystem is CACaller {
  function buildCAWorld(address callerAddress, bytes32 bodyTypeId, VoxelCoord memory coord) public override {
    return super.buildCAWorld(callerAddress, bodyTypeId, coord);
  }

  function mineCAWorld(address callerAddress, bytes32 bodyTypeId, VoxelCoord memory coord) public override {
    return super.mineCAWorld(callerAddress, bodyTypeId, coord);
  }

  function moveCAWorld(
    address callerAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public override returns (bytes32, bytes32) {
    return super.moveCAWorld(callerAddress, bodyTypeId, oldCoord, newCoord);
  }
}
