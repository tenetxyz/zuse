// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { ElectronTunnelSpot, ElectronTunnelSpotData, ElectronTunnelSpotTableId } from "@tenet-level1-ca/src/codegen/Tables.sol";
import { AirVoxelID, ElectronVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCANeighbours, positionDataToVoxelCoord, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract ElectronSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    if (neighbourEntityId == 0) {
      return (false, entityData);
    }
    VoxelCoord memory baseCoord = getCAEntityPositionStrict(IStore(_world()), interactEntity);
    (bytes32[] memory neighbourEntityIds, BlockDirection[] memory neighbourEntityDirections) = getCANeighbours(
      IStore(_world()),
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
    (uint256 otherReplusionForce, VoxelCoord memory otherCoord) = calculateOtherReplusionForce(
      callerAddress,
      interactEntity,
      baseCoord
    );
    // return entityShouldInteract(callerAddress, neighbourEntityId);
    if (otherReplusionForce < currentReplusionForce) {
      return (true, entityData);
    }
    return (false, entityData);
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
      bytes32 neighbourEntityType = getCAVoxelType(neighbourEntityId);
      if (neighbourEntityType == ElectronVoxelID) {
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
    VoxelCoord memory baseCoord
  ) internal returns (uint256, VoxelCoord memory) {
    bool atTop = ElectronTunnelSpot.get(callerAddress, interactEntity).atTop;
    VoxelCoord memory otherCoord;
    if (atTop) {
      otherCoord = VoxelCoord(baseCoord.x, baseCoord.y, baseCoord.z - 1);
    } else {
      otherCoord = VoxelCoord(baseCoord.x, baseCoord.y, baseCoord.z + 1);
    }
    bytes32 otherEntity = getCAEntityAtCoord(IStore(_world()), callerAddress, otherCoord);
    (
      bytes32[] memory otherNeighbourEntityIds,
      BlockDirection[] memory otherNeighbourEntityDirections
    ) = getCANeighbours(IStore(_world()), callerAddress, otherCoord);
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

  function requireValidElectronSpot(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections
  ) internal {
    bool interactAtTop = ElectronTunnelSpot.get(callerAddress, interactEntity).atTop;
    // Check if block south of us is an electron, if so revert
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];
      if (neighbourEntityId == 0) {
        continue;
      }
      bytes32 neighbourEntityType = getCAVoxelType(neighbourEntityId);
      if (interactAtTop && neighbourEntityDirections[i] == BlockDirection.North) {
        if (neighbourEntityType == ElectronVoxelID) {
          revert("ElectronSystem: Cannot place electron when it's tunneling spot is already occupied (north)");
        }

        VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityId);
        // Check one above
        bytes32 aboveEntity = getCAEntityAtCoord(
          IStore(_world()),
          callerAddress,
          VoxelCoord(neighbourCoord.x, neighbourCoord.y, neighbourCoord.z - 1)
        );

        if (aboveEntity != 0) {
          if (hasKey(ElectronTunnelSpotTableId, ElectronTunnelSpot.encodeKeyTuple(callerAddress, aboveEntity))) {
            ElectronTunnelSpotData memory electronTunnelData = ElectronTunnelSpot.get(callerAddress, aboveEntity);
            if (electronTunnelData.atTop || electronTunnelData.sibling == interactEntity) {} else {
              revert(
                "ElectronSystem: Cannot place electron when it's tunneling spot is already occupied (north above)"
              );
            }
          }
        }
      } else if (!interactAtTop && neighbourEntityDirections[i] == BlockDirection.South) {
        if (neighbourEntityType == ElectronVoxelID) {
          bool neighbourAtTop = ElectronTunnelSpot.get(callerAddress, neighbourEntityType).atTop;
          if (neighbourAtTop) {
            revert("ElectronSystem: Cannot place electron when it's tunneling spot is already occupied (south)");
          }
        }
      }
    }
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    VoxelCoord memory baseCoord = getCAEntityPositionStrict(IStore(_world()), interactEntity);

    requireValidElectronSpot(callerAddress, interactEntity, neighbourEntityIds, neighbourEntityDirections);

    // We want to compare the replusion force at where we are, and at our other tunneling spot which is 1 block south of us
    uint256 currentReplusionForce = calculateReplusionForce(
      callerAddress,
      interactEntity,
      neighbourEntityIds,
      neighbourEntityDirections,
      0
    );
    (uint256 otherReplusionForce, VoxelCoord memory otherCoord) = calculateOtherReplusionForce(
      callerAddress,
      interactEntity,
      baseCoord
    );
    if (otherReplusionForce < currentReplusionForce) {
      // Tunnel to that spot
      // IWorld(_world()).mineCAWorld(callerAddress, ElectronVoxelID, baseCoord);
      // IWorld(_world()).buildCAWorld(callerAddress, ElectronVoxelID, otherCoord);
      moveHelper(callerAddress, interactEntity, baseCoord, otherCoord);
      // changedEntity = true;
    }
  }

  function moveHelper(
    address callerAddress,
    bytes32 interactEntity,
    VoxelCoord memory baseCoord,
    VoxelCoord memory otherCoord
  ) internal {
    bool interactAtTop = ElectronTunnelSpot.get(callerAddress, interactEntity).atTop;
    // (bytes32 oldEntityId, bytes32 newEntityId) = IWorld(_world()).moveCAWorld(
    //   callerAddress,
    //   ElectronVoxelID,
    //   baseCoord,
    //   otherCoord
    // );
    // require(newEntityId == interactEntity, "ElectronSystem: New entity id does not match interact entity");
    // ElectronTunnelSpot.set(callerAddress, interactEntity, !interactAtTop, oldEntityId);
    // ElectronTunnelSpot.set(callerAddress, oldEntityId, interactAtTop, interactEntity);
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    bytes32 entityType = getCAVoxelType(entityId);
    return entityType == ElectronVoxelID;
  }

  function eventHandlerElectron(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory, bytes[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
