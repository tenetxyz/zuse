// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { ActivateEvent } from "@tenet-base-world/src/prototypes/ActivateEvent.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { ActivateEventData } from "@tenet-base-world/src/Types.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { ActivateWorldEventData } from "@tenet-world/src/Types.sol";
import { onActivate, postTx } from "@tenet-simulator/src/CallUtils.sol";

contract ActivateSystem is ActivateEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function processCAEvents(EntityEventData[] memory entitiesEventData) internal override {
    IWorld(_world()).caEventsHandler(entitiesEventData);
  }

  // Called by users
  function activateWithAgent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory agentEntity,
    bytes4 interactionSelector
  ) public returns (VoxelEntity memory) {
    ActivateWorldEventData memory activateEventData = ActivateWorldEventData({ agentEntity: agentEntity });
    return
      activate(
        voxelTypeId,
        coord,
        abi.encode(
          ActivateEventData({ worldData: abi.encode(activateEventData), interactionSelector: interactionSelector })
        )
      );
  }

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    EntityEventData[] memory entitiesEventData
  ) internal override {
    super.postEvent(voxelTypeId, coord, eventVoxelEntity, eventData, entitiesEventData);
    ActivateEventData memory activateEventData = abi.decode(eventData, (ActivateEventData));
    ActivateWorldEventData memory activateWorldEventData = abi.decode(
      activateEventData.worldData,
      (ActivateWorldEventData)
    );
    postTx(SIMULATOR_ADDRESS, activateWorldEventData.agentEntity, eventVoxelEntity, coord);
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal override returns (VoxelEntity memory) {
    eventVoxelEntity = super.preRunCA(caAddress, voxelTypeId, coord, eventVoxelEntity, eventData);
    ActivateEventData memory activateEventData = abi.decode(eventData, (ActivateEventData));
    ActivateWorldEventData memory activateWorldEventData = abi.decode(
      activateEventData.worldData,
      (ActivateWorldEventData)
    );
    onActivate(SIMULATOR_ADDRESS, activateWorldEventData.agentEntity, eventVoxelEntity, coord);
    return eventVoxelEntity;
  }
}
