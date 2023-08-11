// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CACaller } from "../prototypes/CACaller.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

contract CACallerSystem is CACaller {
  function buildCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    return super.buildCAWorld(callerAddress, voxelTypeId, coord);
  }

  function mineCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    return super.mineCAWorld(callerAddress, voxelTypeId, coord);
  }
}
