// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@base-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CAVoxelType, CAPosition, CAPositionData, CAPositionTableId, ElectronTunnelSpot, ElectronTunnelSpotData, ElectronTunnelSpotTableId } from "@base-ca/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { EMPTY_ID, AirVoxelID, AirVoxelVariantID, DirtVoxelID, BedrockVoxelID, DirtVoxelVariantID, GrassVoxelID, GrassVoxelVariantID, BedrockVoxelVariantID } from "@base-ca/src/Constants.sol";
import { getEntityAtCoord, voxelCoordToPositionData } from "@base-ca/src/Utils.sol";

contract BaseCASystem is System {
  function isVoxelTypeAllowed(bytes32 voxelTypeId) public pure returns (bool) {
    if (
      voxelTypeId == AirVoxelID ||
      voxelTypeId == DirtVoxelID ||
      voxelTypeId == GrassVoxelID ||
      voxelTypeId == BedrockVoxelID
    ) {
      return true;
    }
    return false;
  }

  function enterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
    address callerAddress = _msgSender();

    require(isVoxelTypeAllowed(voxelTypeId), "This voxel type is not allowed in this CA");

    // Check if we can set the voxel type at this position
    bytes32[][] memory entitiesAtPosition = getKeysWithValue(
      CAPositionTableId,
      CAPosition.encode(coord.x, coord.y, coord.z)
    );
    bytes32 existingEntity = getEntityAtCoord(callerAddress, voxelCoordToPositionData(coord));
    if (existingEntity != 0) {
      require(
        CAVoxelType.get(callerAddress, existingEntity).voxelTypeId == AirVoxelID,
        "This position is already occupied by another voxel"
      );
    } else {
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    }

    if (voxelTypeId == BedrockVoxelID) {
      // TODO: move to ElectronSystem
      // Check one above
      CAPositionData memory aboveCoord = CAPositionData(coord.x, coord.y, coord.z + 1);
      bytes32 aboveEntity = getEntityAtCoord(callerAddress, aboveCoord);
      if (hasKey(ElectronTunnelSpotTableId, ElectronTunnelSpot.encodeKeyTuple(callerAddress, entity))) {
        ElectronTunnelSpotData memory electronTunnelData = ElectronTunnelSpot.get(callerAddress, entity);
        if (electronTunnelData.atTop) {
          if (CAVoxelType.getVoxelTypeId(callerAddress, electronTunnelData.sibling) == AirVoxelID) {
            ElectronTunnelSpot.setAtTop(callerAddress, entity, false);
            ElectronTunnelSpot.setAtTop(callerAddress, electronTunnelData.sibling, false);
          }
        } else {
          if (CAVoxelType.getVoxelTypeId(callerAddress, electronTunnelData.sibling) == AirVoxelID) {
            ElectronTunnelSpot.setAtTop(callerAddress, entity, true);
            ElectronTunnelSpot.setAtTop(callerAddress, electronTunnelData.sibling, true);
          }
        }
      } else {
        if (aboveEntity != 0) {
          if (CAVoxelType.getVoxelTypeId(callerAddress, aboveEntity) == BedrockVoxelID) {
            bool neighbourAtTop = ElectronTunnelSpot.get(callerAddress, aboveEntity).atTop;
            if (neighbourAtTop) {
              revert("ElectronSystem: Cannot place electron when it's tunneling spot is already occupied (south)");
            } else {
              ElectronTunnelSpot.set(callerAddress, entity, true, 0);
            }
          } else {
            if (hasKey(ElectronTunnelSpotTableId, ElectronTunnelSpot.encodeKeyTuple(callerAddress, aboveEntity))) {
              if (ElectronTunnelSpot.get(callerAddress, aboveEntity).atTop) {
                ElectronTunnelSpot.set(callerAddress, aboveEntity, false, entity);
                ElectronTunnelSpot.set(callerAddress, entity, false, aboveEntity);
              } else {
                // ElectronTunnelSpot.set(callerAddress, entity, true, 0);
                revert("how you here");
              }
            }
          }
        } else {
          ElectronTunnelSpot.set(callerAddress, entity, true, 0);
        }
      }
    }

    bytes32 voxelVariantId = getVoxelVariant(voxelTypeId, entity);
    CAVoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId);
  }

  function getVoxelVariant(bytes32 voxelTypeId, bytes32 entity) public view returns (bytes32) {
    if (voxelTypeId == AirVoxelID) {
      return AirVoxelVariantID;
    } else if (voxelTypeId == DirtVoxelID) {
      return DirtVoxelVariantID;
    } else if (voxelTypeId == GrassVoxelID) {
      return GrassVoxelVariantID;
    } else if (voxelTypeId == BedrockVoxelID) {
      return BedrockVoxelVariantID;
    } else {
      revert("This voxel type is not allowed in this CA");
    }
  }

  function exitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
    require(voxelTypeId != AirVoxelID, "can not mine air");

    address callerAddress = _msgSender();
    if (!hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity))) {
      // If there is no entity at this position, try mining the terrain voxel at this position
      bytes32 terrainVoxelTypeId = IWorld(_world()).getTerrainVoxel(coord);
      require(terrainVoxelTypeId != EMPTY_ID && terrainVoxelTypeId == voxelTypeId, "invalid terrain voxel type");
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    }
    // set to Air
    bytes32 airVoxelVariantId = getVoxelVariant(AirVoxelID, entity);
    CAVoxelType.set(callerAddress, entity, AirVoxelID, airVoxelVariantId);

    // TODO: need to remove entities from ElectronTunnelSpot
  }

  function runInteraction(
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32[] memory changedEntities) {
    address callerAddress = _msgSender();

    changedEntities = new bytes32[](neighbourEntityIds.length + 1);

    (bytes32 changedCenterEntityId, bytes32[] memory changedNeighbourEntityIds) = IWorld(_world()).electronEventHandler(
      callerAddress,
      interactEntity,
      neighbourEntityIds
    );
    changedEntities[0] = changedCenterEntityId;
    for (uint256 i = 0; i < changedNeighbourEntityIds.length; i++) {
      changedEntities[i + 1] = changedNeighbourEntityIds[i];
    }

    return changedNeighbourEntityIds;
  }
}
