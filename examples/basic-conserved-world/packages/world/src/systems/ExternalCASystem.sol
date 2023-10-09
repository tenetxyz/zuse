// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord, VoxelEntity, BodySimData, ObjectType } from "@tenet-utils/src/Types.sol";
import { ExternalCASystem as ExternalCAPrototype } from "@tenet-base-world/src/prototypes/ExternalCASystem.sol";
import { getVoxelCoordStrict as utilGetVoxelCoordStrict, getEntityAtCoord as utilGetEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Object } from "@tenet-simulator/src/codegen/tables/Object.sol";
import { Action, ActionData } from "@tenet-simulator/src/codegen/tables/Action.sol";

contract ExternalCASystem is ExternalCAPrototype {
  function getVoxelTypeId(VoxelEntity memory entity) public view override returns (bytes32) {
    return super.getVoxelTypeId(entity);
  }

  function getVoxelCoordStrict(VoxelEntity memory entity) public view returns (VoxelCoord memory) {
    return utilGetVoxelCoordStrict(entity);
  }

  function getEntityAtCoord(uint32 scale, VoxelCoord memory coord) public view returns (bytes32) {
    return utilGetEntityAtCoord(scale, coord);
  }

  function getEntitySimData(VoxelEntity memory entity) public view returns (BodySimData memory) {
    uint256 energy = Energy.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    uint256 mass = Mass.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    bytes memory velocity = Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    uint256 lastUpdateBlock = Velocity.getLastUpdateBlock(
      IStore(SIMULATOR_ADDRESS),
      _world(),
      entity.scale,
      entity.entityId
    );
    uint256 health = Health.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    uint256 stamina = Stamina.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    ObjectType objectType = Object.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    ActionData memory actionData = Action.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);

    return
      BodySimData({
        energy: energy,
        mass: mass,
        velocity: velocity,
        lastUpdateBlock: lastUpdateBlock,
        health: health,
        stamina: stamina,
        objectType: objectType,
        actionData: actionData
      });
  }

  function shouldRunInteractionForNeighbour(
    VoxelEntity memory originEntity,
    VoxelEntity memory neighbourEntity
  ) public view override returns (bool) {
    return true;
  }

  function calculateMooreNeighbourEntities(
    VoxelEntity memory centerEntity,
    uint8 neighbourRadius
  ) public view override returns (bytes32[] memory, VoxelCoord[] memory) {
    return super.calculateMooreNeighbourEntities(centerEntity, neighbourRadius);
  }

  function calculateNeighbourEntities(
    VoxelEntity memory centerEntity
  ) public view override returns (bytes32[] memory, VoxelCoord[] memory) {
    return super.calculateNeighbourEntities(centerEntity);
  }

  function calculateChildEntities(VoxelEntity memory entity) public view override returns (bytes32[] memory) {
    return super.calculateChildEntities(entity);
  }

  function calculateParentEntity(VoxelEntity memory entity) public view override returns (bytes32) {
    return super.calculateParentEntity(entity);
  }
}
