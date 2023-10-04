// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord, VoxelEntity, BodyPhysicsData } from "@tenet-utils/src/Types.sol";
import { ExternalCASystem as ExternalCAPrototype } from "@tenet-base-world/src/prototypes/ExternalCASystem.sol";
import { getVoxelCoordStrict as utilGetVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

contract ExternalCASystem is ExternalCAPrototype {
  function getVoxelTypeId(VoxelEntity memory entity) public view override returns (bytes32) {
    return super.getVoxelTypeId(entity);
  }

  function getVoxelCoordStrict(VoxelEntity memory entity) public view returns (VoxelCoord memory) {
    return utilGetVoxelCoordStrict(entity);
  }

  function getEntityBodyPhysics(VoxelEntity memory entity) public view returns (BodyPhysicsData memory) {
    uint256 energy = Energy.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    uint256 mass = Mass.get(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    bytes memory velocity = Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), _world(), entity.scale, entity.entityId);
    uint256 lastUpdateBlock = Velocity.getLastUpdateBlock(
      IStore(SIMULATOR_ADDRESS),
      _world(),
      entity.scale,
      entity.entityId
    );

    return BodyPhysicsData({ energy: energy, mass: mass, velocity: velocity, lastUpdateBlock: lastUpdateBlock });
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
