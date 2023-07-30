// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CA } from "@tenet-base-ca/src/prototypes/CA.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Level3AirVoxelID } from "@tenet-level3-ca/src/Constants.sol";

contract CASystem is CA {
  function emptyVoxelId() internal pure override returns (bytes32) {
    return Level3AirVoxelID;
  }

  function terrainGen(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) public override {
    revert("Level2CA: Terrain gen not implemented");
  }
}
