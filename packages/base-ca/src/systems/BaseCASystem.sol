// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CAVoxelType, CAPosition, CAPositionData, CAPositionTableId } from "@base-ca/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-registry/src/Types.sol";
import { AirVoxelID, AirVoxelVariantID, DirtVoxelID, DirtVoxelVariantID, GrassVoxelID, GrassVoxelVariantID } from "@base-ca/src/Constants.sol";

contract BaseCASystem is System {
  function isVoxelTypeAllowed(bytes32 voxelTypeId) public returns (bool) {
    if (voxelTypeId == AirVoxelID || voxelTypeId == DirtVoxelID || voxelTypeId == GrassVoxelID) {
      return true;
    }
    return false;
  }

  function enterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
    address callerAddress = msg.sender;

    require(isVoxelTypeAllowed(voxelTypeId), "This voxel type is not allowed in this CA");

    // Check if we can set the voxel type at this position
    bytes32[][] memory entitiesAtPosition = getKeysWithValue(
      CAPositionTableId,
      CAPosition.encode(coord.x, coord.y, coord.z)
    );
    require(entitiesAtPosition.length <= 1, "This position is already occupied by another voxel");
    if (entitiesAtPosition.length == 1) {
      require(
        entitiesAtPosition[0][0] == callerAddress &&
          entitiesAtPosition[0][1] == entity &&
          CAVoxelType.get(callerAddress, entitiesAtPosition[0][1]).voxelTypeId == AirVoxelID,
        "This position is already occupied by another voxel"
      );
    } else {
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    }

    bytes32 voxelVariantId = updateVoxelVariant(voxelTypeId, entity);
    CAVoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId);
  }

  function updateVoxelVariant(bytes32 voxelTypeId, bytes32 entity) public returns (bytes32 voxelVariantId) {
    if (voxelTypeId == AirVoxelID) {
      return AirVoxelVariantID;
    } else if (voxelTypeId == DirtVoxelID) {
      return DirtVoxelVariantID;
    } else if (voxelTypeId == GrassVoxelID) {
      return GrassVoxelVariantID;
    } else {
      revert("This voxel type is not allowed in this CA");
    }
  }

  function exitWorld(bytes32 entity) public {
    address callerAddress = msg.sender;
    require(
      hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity)),
      "This entity is not in the world"
    );
    // set to Air
    bytes32 airVoxelVariantId = updateVoxelVariant(AirVoxelID, entity);
    CAVoxelType.set(callerAddress, entity, AirVoxelID, airVoxelVariantId);
  }

  function runInteraction(
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32[] memory parentEntityIds
  ) public returns (bytes32[] memory changedEntities) {
    // loop over all neighbours and run interaction logic
    // the interaction's used will can be in different namespaces
    // can change type at position
    // keep looping until no more type and position changes
  }
}
