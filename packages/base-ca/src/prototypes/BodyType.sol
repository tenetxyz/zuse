// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";

// Represents a body
abstract contract BodyType is System {
  function getCallerAddress() public view returns (address) {
    address callerAddress = getFirstCaller();
    if (callerAddress == address(0)) {
      callerAddress = _msgSender();
    }
    return callerAddress;
  }

  // Called once to register the body into the registry
  function registerBody() public virtual;

  // Called by the CA every time the body is placed in the world
  function enterWorld(VoxelCoord memory coord, bytes32 entity) public virtual;

  // Called by the CA every time the body is removed from the world
  function exitWorld(VoxelCoord memory coord, bytes32 entity) public virtual;

  // Called by the CA to determine which variant (or graphic) of the body to use
  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view virtual returns (bytes32 voxelVariantId);

  // Called by the CA when the player right clicks it
  function activate(bytes32 entity) public view virtual returns (string memory);
}
