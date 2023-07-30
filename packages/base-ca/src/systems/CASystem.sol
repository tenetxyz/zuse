// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CA } from "../prototypes/CA.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

contract CASystem is CA {
  function emptyVoxelId() internal pure override returns (bytes32) {
    return AirVoxelID;
  }

  function terrainGen(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) public override {
    revert("BaseCA: Terrain gen not implemented");
  }
}
