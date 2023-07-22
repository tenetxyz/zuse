// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { VoxelType, Position, PositionData, PositionTableId } from "@base-ca/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-registry/src/Types.sol";

bytes32 constant AirVoxelID = bytes32(keccak256("air"));
bytes32 constant AirVoxelVariantID = bytes32(keccak256("air"));

bytes32 constant DirtVoxelID = bytes32(keccak256("dirt"));
bytes32 constant DirtVoxelVariantID = bytes32(keccak256("dirt"));

bytes32 constant GrassVoxelID = bytes32(keccak256("grass"));
bytes32 constant GrassVoxelVariantID = bytes32(keccak256("grass"));

contract BaseCASystem is System {
  function isVoxelTypeAllowed(bytes32 voxelTypeId) public returns (bool) {
    if (voxelTypeId == AirID || voxelTypeId == DirtID || voxelTypeId == GrassID) {
      return true;
    }
    return false;
  }

  function enterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
    address callerAddress = msg.sender;

    require(isVoxelTypeAllowed(voxelTypeId), "This voxel type is not allowed in this CA");

    // Check if we can set the voxel type at this position
    bytes32[] memory entitiesAtPosition = getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));
    require(entitiesAtPosition.length <= 1, "This position is already occupied by another voxel");
    if (entitiesAtPosition.length == 1) {
      require(
        entitiesAtPosition[0] == entity,
        VoxelType.get(callerAddress, entitiesAtPosition[0]).voxelTypeId == AirID,
        "This position is already occupied by another voxel"
      );
      VoxelType.deleteRecord(entitiesAtPosition[0]);
    } else {
      Position.set(callerAddress, entity, PositionData({ x: coord.x, y: coord.y, z: coord.z }));
    }

    bytes32 voxelVariantId = updateVoxelVariant(voxelTypeId, entity);
    VoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId);
  }

  function updateVoxelVariant(bytes32 voxelTypeId, bytes32 entity) public returns (bytes32 voxelVariantId) {
    if (voxelTypeId == AirID) {
      return AirVoxelVariantID;
    } else if (voxelTypeId == DirtID) {
      return DirtVoxelVariantID;
    } else if (voxelTypeId == GrassID) {
      return GrassVoxelVariantID;
    } else {
      revert("This voxel type is not allowed in this CA");
    }
  }

  function exitWorld(bytes32 entity) public {
    address callerAddress = msg.sender;
    bytes32[] memory positionKeyTuple = new bytes32[](0);
    positionKeyTuple[0] = callerAddress;
    positionKeyTuple[1] = entity;
    require(hasKey(PositionTableId, positionKeyTuple), "This entity is not in the world");
    // set to Air
    bytes32 airVoxelVariantId = updateVoxelVariant(AirID, entity);
    VoxelType.set(callerAddress, entity, AirID, airVoxelVariantId);
  }

  // // called by world
  // function runInteraction(
  //   bytes32 interactEntity,
  //   bytes32[] memory neighbourEntityIds,
  //   bytes32[] memory childEntityIds,
  //   bytes32[] memory parentEntityIds
  // ) public {
  //   // loop over all neighbours and run interaction logic
  //   // the interaction's used will can be in different namespaces
  //   // just hard coded, or registered
  //   runInteractionSystems(entity);

  //   // can change type at position
  //   // define valid movements
  // }
}
