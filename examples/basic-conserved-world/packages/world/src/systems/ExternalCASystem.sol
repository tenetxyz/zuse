// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { ExternalCASystem as ExternalCAPrototype } from "@tenet-base-world/src/prototypes/ExternalCASystem.sol";
import { BodyPhysics, BodyPhysicsData } from "@tenet-world/src/codegen/Tables.sol";

contract ExternalCASystem is ExternalCAPrototype {
  function getVoxelTypeId(VoxelEntity memory entity) public view override returns (bytes32) {
    return super.getVoxelTypeId(entity);
  }

  function getEntityBodyPhysics(VoxelEntity memory entity) public view returns (BodyPhysicsData memory) {
    return BodyPhysics.get(entity.scale, entity.entityId);
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

  function calculateNeighbourEntities(VoxelEntity memory centerEntity) public view override returns (bytes32[] memory) {
    return super.calculateNeighbourEntities(centerEntity);
  }

  function calculateChildEntities(VoxelEntity memory entity) public view override returns (bytes32[] memory) {
    return super.calculateChildEntities(entity);
  }

  function calculateParentEntity(VoxelEntity memory entity) public view override returns (bytes32) {
    return super.calculateParentEntity(entity);
  }
}
