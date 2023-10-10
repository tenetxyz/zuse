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
import { Nutrients } from "@tenet-simulator/src/codegen/tables/Nutrients.sol";
import { Nitrogen } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorous } from "@tenet-simulator/src/codegen/tables/Phosphorous.sol";
import { Potassium } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { Elixir } from "@tenet-simulator/src/codegen/tables/Elixir.sol";
import { Protein } from "@tenet-simulator/src/codegen/tables/Protein.sol";

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
    BodySimData memory entitySimData;

    entitySimData.energy = Energy.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.mass = Mass.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.velocity = Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.lastUpdateBlock = Velocity.getLastUpdateBlock(
      IStore(SIMULATOR_ADDRESS),
      _world(),
      entity.scale,
      entity.entityId
    );
    entitySimData.health = Health.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.stamina = Stamina.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.objectType = Object.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.actionData = Action.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.nutrients = Nutrients.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.nitrogen = Nitrogen.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.phosphorous = Phosphorous.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.potassium = Potassium.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.elixir = Elixir.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    entitySimData.protein = Protein.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);

    return entitySimData;
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
