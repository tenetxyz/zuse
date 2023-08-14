// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Mind } from "@tenet-base-ca/src/prototypes/Mind.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

contract FighterMind is Mind {
  function registerMind() public override {}

  function mindLogic(
    bytes32 voxelTypeId,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes4) {
    return 0;
  }
}
