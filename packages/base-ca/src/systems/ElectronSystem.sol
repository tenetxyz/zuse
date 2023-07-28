// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@base-ca/src/codegen/world/IWorld.sol";
import { VoxelInteraction } from "@base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { ElectronTunnelSpot, ElectronTunnelSpotData, ElectronTunnelSpotTableId, CAVoxelType, CAPosition, CAPositionData, CAPositionTableId } from "@base-ca/src/codegen/Tables.sol";
import { AirVoxelID, DirtVoxelID, GrassVoxelID, BedrockVoxelID } from "@base-ca/src/Constants.sol";
import { getEntityAtCoord, getNeighbours, positionDataToVoxelCoord } from "@base-ca/src/Utils.sol";
import { buildWorld, mineWorld } from "@base-ca/src/CallUtils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract ElectronSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity) {
    if (neighbourEntityId == 0) {
      return false;
    }
    CAPositionData memory baseCoord = CAPosition.get(callerAddress, interactEntity);
    (bytes32[] memory neighbourEntityIds, BlockDirection[] memory neighbourEntityDirections) = getNeighbours(
      callerAddress,
      baseCoord
    );
    uint256 currentReplusionForce = calculateReplusionForce(
      callerAddress,
      interactEntity,
      neighbourEntityIds,
      neighbourEntityDirections,
      0
    );
    (uint256 otherReplusionForce, CAPositionData memory otherCoord) = calculateOtherReplusionForce(
      callerAddress,
      interactEntity,
      baseCoord
    );
    // return entityShouldInteract(callerAddress, neighbourEntityId);
    if (otherReplusionForce < currentReplusionForce) {
      return true;
    }
    return false;
  }

  function calculateReplusionForce(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32 excludingEntityId
  ) internal returns (uint256) {
    // Need to check all neighbours and see if they are electrons
    // First we check ones that are just close to us
    uint256 replusionForce = 0;

    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];
      if (neighbourEntityId == 0 || neighbourEntityId == excludingEntityId) {
        continue;
      }
      bytes32 neighbourEntityType = CAVoxelType.getVoxelTypeId(callerAddress, neighbourEntityId);
      if (neighbourEntityType == BedrockVoxelID) {
        require(neighbourEntityDirections[i] != BlockDirection.None, "ElectronSystem: Invalid direction");
        if (
          neighbourEntityDirections[i] == BlockDirection.North ||
          neighbourEntityDirections[i] == BlockDirection.South ||
          neighbourEntityDirections[i] == BlockDirection.East ||
          neighbourEntityDirections[i] == BlockDirection.West
        ) {
          replusionForce += 5;
        } else {
          // it's a diagonal, so distance is smaller, so smaller force
          replusionForce += 1;
        }
      }
    }

    return replusionForce;
  }

  function calculateOtherReplusionForce(
    address callerAddress,
    bytes32 interactEntity,
    CAPositionData memory baseCoord
  ) internal returns (uint256, CAPositionData memory) {
    bool atTop = ElectronTunnelSpot.get(callerAddress, interactEntity).atTop;
    CAPositionData memory otherCoord;
    if (atTop) {
      otherCoord = CAPositionData(baseCoord.x, baseCoord.y, baseCoord.z - 1);
    } else {
      otherCoord = CAPositionData(baseCoord.x, baseCoord.y, baseCoord.z + 1);
    }
    bytes32 otherEntity = getEntityAtCoord(callerAddress, otherCoord);
    (bytes32[] memory otherNeighbourEntityIds, BlockDirection[] memory otherNeighbourEntityDirections) = getNeighbours(
      callerAddress,
      otherCoord
    );
    return (
      calculateReplusionForce(
        callerAddress,
        otherEntity,
        otherNeighbourEntityIds,
        otherNeighbourEntityDirections,
        interactEntity
      ),
      otherCoord
    );
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections
  ) internal override returns (bool changedEntity) {
    CAPositionData memory baseCoord = CAPosition.get(callerAddress, interactEntity);
    bool interactAtTop = ElectronTunnelSpot.get(callerAddress, interactEntity).atTop;
    // Check if block south of us is an electron, if so revert
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];
      if (neighbourEntityId == 0) {
        continue;
      }
      bytes32 neighbourEntityType = CAVoxelType.getVoxelTypeId(callerAddress, neighbourEntityId);
      if (interactAtTop && neighbourEntityDirections[i] == BlockDirection.North) {
        if (neighbourEntityType == BedrockVoxelID) {
          revert("ElectronSystem: Cannot place electron when it's tunneling spot is already occupied (north)");
        }

        CAPositionData memory neighbourCoord = CAPosition.get(callerAddress, neighbourEntityId);
        // Check one above
        CAPositionData memory aboveCoord = CAPositionData(neighbourCoord.x, neighbourCoord.y, neighbourCoord.z - 1);
        bytes32 aboveEntity = getEntityAtCoord(callerAddress, aboveCoord);

        if (aboveEntity != 0) {
          if (hasKey(ElectronTunnelSpotTableId, ElectronTunnelSpot.encodeKeyTuple(callerAddress, aboveEntity))) {
            ElectronTunnelSpotData memory electronTunnelData = ElectronTunnelSpot.get(callerAddress, aboveEntity);
            if (electronTunnelData.atTop || electronTunnelData.sibling == interactEntity) {} else {
              revert(
                string(
                  abi.encode(
                    "ElectronSystem: Cannot place electron when it's tunneling spot is already occupied (north above)",
                    Strings.toString(uint256(interactEntity)),
                    Strings.toString(baseCoord.x),
                    Strings.toString(baseCoord.y),
                    Strings.toString(baseCoord.z),
                    Strings.toString(uint256(aboveEntity)),
                    Strings.toString(aboveCoord.x),
                    Strings.toString(aboveCoord.y),
                    Strings.toString(aboveCoord.z)
                  )
                )
              );
            }
          }
        }
      } else if (!interactAtTop && neighbourEntityDirections[i] == BlockDirection.South) {
        if (neighbourEntityType == BedrockVoxelID) {
          bool neighbourAtTop = ElectronTunnelSpot.get(callerAddress, neighbourEntityType).atTop;
          if (neighbourAtTop) {
            revert("ElectronSystem: Cannot place electron when it's tunneling spot is already occupied (south)");
          }
        }
      }
    }

    // We want to compare the replusion force at where we are, and at our other tunneling spot which is 1 block south of us
    uint256 currentReplusionForce = calculateReplusionForce(
      callerAddress,
      interactEntity,
      neighbourEntityIds,
      neighbourEntityDirections,
      0
    );
    (uint256 otherReplusionForce, CAPositionData memory otherCoord) = calculateOtherReplusionForce(
      callerAddress,
      interactEntity,
      baseCoord
    );
    if (otherReplusionForce < currentReplusionForce) {
      // Tunnel to that spot
      mineWorld(callerAddress, BedrockVoxelID, positionDataToVoxelCoord(baseCoord));
      buildWorld(callerAddress, BedrockVoxelID, positionDataToVoxelCoord(otherCoord));
      // changedEntity = true;
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
