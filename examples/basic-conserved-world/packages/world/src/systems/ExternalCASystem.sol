// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord, VoxelEntity, BodySimData, ObjectType } from "@tenet-utils/src/Types.sol";
import { ExternalCASystem as ExternalCAPrototype } from "@tenet-base-world/src/prototypes/ExternalCASystem.sol";
import { getVoxelCoordStrict as utilGetVoxelCoordStrict, getEntityAtCoord as utilGetEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Object } from "@tenet-simulator/src/codegen/tables/Object.sol";
import { Action, ActionData } from "@tenet-simulator/src/codegen/tables/Action.sol";
import { Nutrients } from "@tenet-simulator/src/codegen/tables/Nutrients.sol";
import { Nitrogen, NitrogenTableId } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorous, PhosphorousTableId } from "@tenet-simulator/src/codegen/tables/Phosphorous.sol";
import { Potassium, PotassiumTableId } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
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
    address worldAddress = _world();
    IStore store = IStore(SIMULATOR_ADDRESS);

    entitySimData.energy = Energy.get(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.mass = Mass.get(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.velocity = Velocity.getVelocity(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.lastUpdateBlock = Velocity.getLastUpdateBlock(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.health = Health.getHealth(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.stamina = Stamina.get(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.objectType = Object.get(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.actionData = Action.get(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.nutrients = Nutrients.get(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.nitrogen = Nitrogen.get(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.hasNitrogen = hasKey(
      store,
      NitrogenTableId,
      Nitrogen.encodeKeyTuple(worldAddress, entity.scale, entity.entityId)
    );
    entitySimData.phosphorous = Phosphorous.get(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.hasPhosphorous = hasKey(
      store,
      PhosphorousTableId,
      Phosphorous.encodeKeyTuple(worldAddress, entity.scale, entity.entityId)
    );
    entitySimData.potassium = Potassium.get(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.hasPotassium = hasKey(
      store,
      PotassiumTableId,
      Potassium.encodeKeyTuple(worldAddress, entity.scale, entity.entityId)
    );
    entitySimData.elixir = Elixir.get(store, worldAddress, entity.scale, entity.entityId);
    entitySimData.protein = Protein.get(store, worldAddress, entity.scale, entity.entityId);

    return entitySimData;
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
