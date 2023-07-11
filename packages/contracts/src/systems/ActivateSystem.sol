// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { PositionTableId, VoxelType, VoxelTypeData, VoxelTypeRegistry } from "@tenet-contracts/src/codegen/Tables.sol";
import { safeCall } from "@tenet-contracts/src/Utils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

contract ActivateSystem is System {
  function activate(bytes32 entity) public returns (bytes32) {
    bytes32[] memory keyTuple = new bytes32[](1);
    keyTuple[0] = entity;
    require(hasKey(PositionTableId, keyTuple), "The entity must be placed in the world");

    VoxelTypeData memory voxelType = VoxelType.get(entity);
    bytes4 activateSelector = VoxelTypeRegistry.getActivateSelector(
      voxelType.voxelTypeNamespace,
      voxelType.voxelTypeId
    );

    safeCall(
      _world(),
      abi.encodeWithSelector(activateSelector, entity),
      string(abi.encode("activate entity: ", Strings.toString(uint256(entity))))
    );
  }
}
