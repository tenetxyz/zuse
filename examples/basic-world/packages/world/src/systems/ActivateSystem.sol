// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { ActivateEvent } from "@tenet-base-world/src/prototypes/ActivateEvent.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { ActivateEventData } from "@tenet-base-world/src/Types.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";

contract ActivateSystem is ActivateEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function processCAEvents(EntityEventData[] memory entitiesEventData) internal override {}

  // Called by users
  function activate(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes4 interactionSelector
  ) public returns (VoxelEntity memory) {
    return
      activate(
        voxelTypeId,
        coord,
        abi.encode(ActivateEventData({ worldData: abi.encode(bytes32(0)), interactionSelector: interactionSelector }))
      );
  }
}
