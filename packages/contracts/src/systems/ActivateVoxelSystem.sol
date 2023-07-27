// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { PositionTableId, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";

contract ActivateVoxelSystem is System {
  function activateVoxel(bytes32 entity) public returns (bytes memory) {
    bytes32[] memory keyTuple = new bytes32[](1);
    keyTuple[0] = entity;
    require(hasKey(PositionTableId, keyTuple), "The entity must be placed in the world");

    // TODO: Change to use the CA once we have it.
    // VoxelTypeData memory voxelType = VoxelType.get(1, entity);
    // bytes4 activateSelector = VoxelTypeRegistry.getActivateSelector(
    //   voxelType.voxelTypeNamespace,
    //   voxelType.voxelTypeId
    // );

    bytes memory activateReturnData;

    // bytes memory activateReturnData = safeCall(
    //     _world(),
    //     abi.encodeWithSelector(activateSelector, entity),
    //     string(abi.encode("activate entity: ", Strings.toString(uint256(entity))))
    // );

    // Run voxel interaction logic
    // IWorld(_world()).runInteractionSystems(entity);

    return activateReturnData;
  }
}
