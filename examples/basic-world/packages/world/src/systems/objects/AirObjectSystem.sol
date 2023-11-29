// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ObjectType } from "@tenet-base-world/src/prototypes/ObjectType.sol";
import { registerObjectType } from "@tenet-registry/src/Utils.sol";
import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, AirObjectID } from "@tenet-world/src/Constants.sol";

contract AirObjectSystem is ObjectType {
  function registerBody() public {
    address world = _world();
    registerObjectType(
      REGISTRY_ADDRESS,
      AirObjectID,
      world,
      IWorld(world).world_AirObjectSystem_enterWorld.selector,
      IWorld(world).world_AirObjectSystem_exitWorld.selector,
      IWorld(world).world_AirObjectSystem_eventHandler.selector,
      IWorld(world).world_AirObjectSystem_neighbourEventHandler.selector,
      "Air",
      ""
    );
  }

  function enterWorld(bytes32 entityId, VoxelCoord memory coord) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    objectProperties.mass = 0;
    return objectProperties;
  }

  function exitWorld(bytes32 entityId, VoxelCoord memory coord) public override {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public override returns (Action[] memory) {
    return new Action[](0);
  }

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, Action[] memory) {
    return (false, new Action[](0));
  }
}