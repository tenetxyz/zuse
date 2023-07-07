// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getCallerNamespace } from "../SharedUtils.sol";
import { PositionTableId } from "../codegen/tables/Position.sol";
import { VoxelVariantsKey } from "../Types.sol";

abstract contract VoxelType is System {
  function registerVoxel() public virtual;

  function addProperties(bytes32 entity, bytes16 callerNamespace) public virtual {}

  function removeProperties(bytes32 entity, bytes16 callerNamespace) public virtual {}

  function setupVoxel(bytes32 entity) public returns (bool voxelExists, bytes16 callerNamespace) {
    callerNamespace = getCallerNamespace(_msgSender());

    bytes32[] memory positionKeyTuple = new bytes32[](1);
    positionKeyTuple[0] = bytes32((entity));
    voxelExists = hasKey(PositionTableId, positionKeyTuple);
    if (voxelExists) {
      addProperties(entity, callerNamespace);
    } else {
      removeProperties(entity, callerNamespace);
    }

    return (voxelExists, callerNamespace);
  }
}
