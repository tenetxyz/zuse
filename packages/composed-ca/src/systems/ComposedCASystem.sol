// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@composed-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CAVoxelType, CAPosition, CAPositionData, CAPositionTableId } from "@composed-ca/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Level2AirVoxelID, RoadVoxelID, RoadVoxelVariantID } from "@composed-ca/src/Constants.sol";
import { AirVoxelVariantID } from "@tenet-base-ca/src/Constants.sol";

contract ComposedCASystem is System {
  function isVoxelTypeAllowed(bytes32 voxelTypeId) public pure returns (bool) {
    if (voxelTypeId == Level2AirVoxelID || voxelTypeId == RoadVoxelID) {
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
    bytes32 existingEntity;
    for (uint256 i = 0; i < entitiesAtPosition.length; i++) {
      if (entitiesAtPosition[i][0] == bytes32(uint256(uint160(callerAddress)))) {
        if (existingEntity != 0) {
          revert("This position is already occupied by another voxel");
        }
        existingEntity = entitiesAtPosition[i][1];
      }
    }
    if (existingEntity != 0) {
      require(
        CAVoxelType.get(callerAddress, existingEntity).voxelTypeId == Level2AirVoxelID,
        "This position is already occupied by another voxel"
      );
    } else {
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    }

    bytes32 voxelVariantId = getVoxelVariant(voxelTypeId, entity);
    CAVoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId);
  }

  function getVoxelVariant(bytes32 voxelTypeId, bytes32 entity) public view returns (bytes32) {
    if (voxelTypeId == Level2AirVoxelID) {
      return AirVoxelVariantID;
    } else if (voxelTypeId == RoadVoxelID) {
      return RoadVoxelVariantID;
    } else {
      revert("This voxel type is not allowed in this CA");
    }
  }

  function exitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
    address callerAddress = _msgSender();
    require(
      hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity)),
      "This entity is not in the world"
    );
    // set to Air
    bytes32 airVoxelVariantId = getVoxelVariant(Level2AirVoxelID, entity);
    CAVoxelType.set(callerAddress, entity, Level2AirVoxelID, airVoxelVariantId);
  }

  function runInteraction(
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32[] memory changedEntities) {
    // loop over all neighbours and run interaction logic
    // the interaction's used will can be in different namespaces
    // can change type at position
    // keep looping until no more type and position changes
  }
}
