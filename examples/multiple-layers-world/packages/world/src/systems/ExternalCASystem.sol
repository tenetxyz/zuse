// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { ExternalCASystem as ExternalCAPrototype } from "@tenet-base-world/src/prototypes/ExternalCASystem.sol";

contract ExternalCASystem is ExternalCAPrototype {
  function getVoxelTypeId(uint32 scale, bytes32 entity) public view override returns (bytes32) {
    return super.getVoxelTypeId(scale, entity);
  }

  function calculateNeighbourEntities(uint32 scale, bytes32 centerEntity) public view override returns (bytes32[] memory) {
    return super.calculateNeighbourEntities(scale, centerEntity);
  }

  // TODO: Make this general by using cube root
  function calculateChildEntities(uint32 scale, bytes32 entity) public view override returns (bytes32[] memory) {
    return super.calculateChildEntities(scale, entity);
  }

  // TODO: Make this general by using cube root
  function calculateParentEntity(uint32 scale, bytes32 entity) public view override returns (bytes32) {
    return super.calculateParentEntity(scale, entity);
  }
}
