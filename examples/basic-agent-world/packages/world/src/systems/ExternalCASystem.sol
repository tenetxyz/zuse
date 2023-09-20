// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelEntity } from "@tenet-utils/src/Types.sol";
import { ExternalCASystem as ExternalCAPrototype } from "@tenet-base-world/src/prototypes/ExternalCASystem.sol";

contract ExternalCASystem is ExternalCAPrototype {
  function getVoxelTypeId(VoxelEntity memory entity) public view override returns (bytes32) {
    return super.getVoxelTypeId(entity);
  }

  function getMindSelector(VoxelEntity memory entity) public override returns (bytes4) {
    return super.getMindSelector(entity);
  }

  function shouldRunInteractionForNeighbour(
    VoxelEntity memory originEntity,
    VoxelEntity memory neighbourEntity
  ) public view override returns (bool) {
    return true;
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
