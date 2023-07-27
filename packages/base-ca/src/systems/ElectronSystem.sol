// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@base-ca/src/codegen/world/IWorld.sol";
import { VoxelInteraction } from "@base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { CAVoxelType, CAPosition, CAPositionData, CAPositionTableId } from "@base-ca/src/codegen/Tables.sol";
import { AirVoxelID, DirtVoxelID, GrassVoxelID, BedrockVoxelID } from "@base-ca/src/Constants.sol";
import { getEntityAtCoord } from "@base-ca/src/Utils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract ElectronSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity) {
    return entityShouldInteract(callerAddress, neighbourEntityId);
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections
  ) internal override returns (bool changedEntity) {
    CAPositionData memory baseCoord = CAPosition.get(callerAddress, interactEntity);
    // Check if block south of us is an electron, if so revert
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];
      if (neighbourEntityId == 0) {
        continue;
      }
      bytes32 neighbourEntityType = CAVoxelType.getVoxelTypeId(callerAddress, neighbourEntityId);
      if (neighbourEntityDirections[i] == BlockDirection.South) {
        if (neighbourEntityType == BedrockVoxelID) {
          revert("ElectronSystem: Cannot place electron when it's tunneling spot is already occupied");
        }
      } else if (neighbourEntityDirections[i] == BlockDirection.North) {
        if (neighbourEntityType == BedrockVoxelID) {
          revert("ElectronSystem: Cannot place electron when it's tunneling spot is already occupied");
        }
        CAPositionData memory neighbourCoord = CAPosition.get(callerAddress, neighbourEntityId);
        // Check one above
        CAPositionData memory aboveCoord = CAPositionData(neighbourCoord.x, neighbourCoord.y, neighbourCoord.z + 1);
        bytes32 aboveEntity = getEntityAtCoord(callerAddress, aboveCoord);
        if (aboveEntity != 0) {
          bytes32 aboveEntityType = CAVoxelType.getVoxelTypeId(callerAddress, aboveEntity);
          if (aboveEntityType == BedrockVoxelID) {
            revert("ElectronSystem: Cannot place electron when it's tunneling spot is already occupied");
          }
        }
      }
    }
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    bytes32 entityType = CAVoxelType.getVoxelTypeId(callerAddress, entityId);
    return entityType == BedrockVoxelID;
  }

  function electronEventHandler(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public returns (bytes32, bytes32[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds);
  }
}
