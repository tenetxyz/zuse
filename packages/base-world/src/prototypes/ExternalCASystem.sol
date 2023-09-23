// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { hasEntity, addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { CAMind } from "@tenet-base-ca/src/codegen/tables/CAMind.sol";
import { MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH } from "@tenet-utils/src/Constants.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData, VoxelTypeTableId } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { WorldConfig } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { VoxelActivated, VoxelActivatedData } from "@tenet-base-world/src/codegen/tables/VoxelActivated.sol";
import { VoxelMind, VoxelMindData } from "@tenet-base-world/src/codegen/tables/VoxelMind.sol";
import { runInteraction, enterWorld, exitWorld, activateVoxel, moveLayer } from "@tenet-base-ca/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityAtCoord, calculateChildCoords, calculateParentCoord } from "@tenet-base-world/src/Utils.sol";
import { getVonNeumannNeighbours, getMooreNeighbours } from "@tenet-utils/src/VoxelCoordUtils.sol";

abstract contract ExternalCASystem is System {
  function getVoxelTypeId(VoxelEntity memory entity) public view virtual returns (bytes32) {
    return VoxelType.getVoxelTypeId(entity.scale, entity.entityId);
  }

  function shouldRunInteractionForNeighbour(
    VoxelEntity memory originEntity,
    VoxelEntity memory neighbourEntity
  ) public view virtual returns (bool);

  function calculateMooreNeighbourEntities(
    VoxelEntity memory centerEntity,
    uint8 neighbourRadius
  ) public view virtual returns (bytes32[] memory, VoxelCoord[] memory) {
    uint32 scale = centerEntity.scale;
    bytes32 centerEntityId = centerEntity.entityId;
    VoxelCoord memory centerCoord = positionDataToVoxelCoord(Position.get(scale, centerEntityId));
    VoxelCoord[] memory neighbourCoords = getMooreNeighbours(centerCoord, neighbourRadius);
    bytes32[] memory neighbourEntities = new bytes32[](neighbourCoords.length);
    for (uint i = 0; i < neighbourCoords.length; i++) {
      bytes32 neighbourEntity = getEntityAtCoord(scale, neighbourCoords[i]);
      if (uint256(neighbourEntity) != 0) {
        neighbourEntities[i] = neighbourEntity;
      } else {
        neighbourEntities[i] = 0;
      }
    }
    return (neighbourEntities, neighbourCoords);
  }

  function calculateNeighbourEntities(
    VoxelEntity memory centerEntity
  ) public view virtual returns (bytes32[] memory, VoxelCoord[] memory) {
    uint32 scale = centerEntity.scale;
    bytes32 centerEntityId = centerEntity.entityId;
    VoxelCoord memory centerCoord = positionDataToVoxelCoord(Position.get(scale, centerEntityId));
    VoxelCoord[] memory neighbourCoords = getVonNeumannNeighbours(centerCoord);
    bytes32[] memory neighbourEntities = new bytes32[](neighbourCoords.length);

    for (uint i = 0; i < neighbourCoords.length; i++) {
      bytes32 neighbourEntity = getEntityAtCoord(scale, neighbourCoords[i]);
      if (uint256(neighbourEntity) != 0) {
        neighbourEntities[i] = neighbourEntity;
      } else {
        neighbourEntities[i] = 0;
      }
    }

    return (neighbourEntities, neighbourCoords);
  }

  // TODO: Make this general by using cube root
  function calculateChildEntities(VoxelEntity memory entity) public view virtual returns (bytes32[] memory) {
    uint32 scale = entity.scale;
    bytes32 entityId = entity.entityId;

    if (scale >= 2) {
      bytes32[] memory childEntities = new bytes32[](8);
      PositionData memory baseCoord = Position.get(scale, entityId);
      VoxelCoord memory baseVoxelCoord = VoxelCoord({ x: baseCoord.x, y: baseCoord.y, z: baseCoord.z });
      VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, baseVoxelCoord);

      for (uint8 i = 0; i < 8; i++) {
        // filter for the ones with scale-1
        bytes32 childEntityAtPosition = getEntityAtCoord(scale - 1, eightBlockVoxelCoords[i]);

        // if (childEntityAtPosition == 0) {
        //   revert("found no child entity");
        // }

        childEntities[i] = childEntityAtPosition;
      }

      return childEntities;
    }

    return new bytes32[](0);
  }

  // TODO: Make this general by using cube root
  function calculateParentEntity(VoxelEntity memory entity) public view virtual returns (bytes32) {
    uint32 scale = entity.scale;
    bytes32 entityId = entity.entityId;

    bytes32 parentEntity;

    PositionData memory baseCoord = Position.get(scale, entityId);
    VoxelCoord memory baseVoxelCoord = VoxelCoord({ x: baseCoord.x, y: baseCoord.y, z: baseCoord.z });
    VoxelCoord memory parentVoxelCoord = calculateParentCoord(2, baseVoxelCoord);
    parentEntity = getEntityAtCoord(scale + 1, parentVoxelCoord);

    return parentEntity;
  }
}
