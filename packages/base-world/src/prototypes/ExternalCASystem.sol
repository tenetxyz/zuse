// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { hasEntity, addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { callOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { CAMind } from "@tenet-base-ca/src/codegen/tables/CAMind.sol";
import { KeysInTable } from "@latticexyz/world/src/modules/keysintable/tables/KeysInTable.sol";
import { Interactions, InteractionsTableId } from "@tenet-base-world/src/codegen/tables/Interactions.sol";
import { MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH, MAX_UNIQUE_ENTITY_INTERACTIONS_RUN, MAX_SAME_VOXEL_INTERACTION_RUN } from "@tenet-utils/src/Constants.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData, VoxelTypeTableId } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { WorldConfig } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
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
  ) public virtual returns (bool) {
    uint256 numInteractionsRan = KeysInTable.lengthKeys0(InteractionsTableId);
    if (numInteractionsRan + 1 > MAX_UNIQUE_ENTITY_INTERACTIONS_RUN) {
      return false;
    }

    if (Interactions.get(neighbourEntity.scale, neighbourEntity.entityId) > MAX_SAME_VOXEL_INTERACTION_RUN) {
      return false;
    }

    Interactions.set(
      neighbourEntity.scale,
      neighbourEntity.entityId,
      Interactions.get(neighbourEntity.scale, neighbourEntity.entityId) + 1
    );

    return true;
  }

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
}
