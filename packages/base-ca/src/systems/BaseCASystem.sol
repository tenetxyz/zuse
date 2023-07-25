// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CAVoxelTypeDefs, CAVoxelTypeDefsTableId, CAVoxelType, CAPosition, CAPositionData, CAPositionTableId } from "@base-ca/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID, AirVoxelVariantID, DirtVoxelID, DirtVoxelVariantID, GrassVoxelID, GrassVoxelVariantID } from "@base-ca/src/Constants.sol";

contract BaseCASystem is System {
  function defineVoxelTypeDefs() public {
    require(
      !hasKey(CAVoxelTypeDefsTableId, CAVoxelTypeDefs.encodeKeyTuple(AirVoxelID)) &&
        !hasKey(CAVoxelTypeDefsTableId, CAVoxelTypeDefs.encodeKeyTuple(DirtVoxelID)) &&
        !hasKey(CAVoxelTypeDefsTableId, CAVoxelTypeDefs.encodeKeyTuple(GrassVoxelID)),
      "The voxel type's has already been defined for this CA"
    );

    bytes32[] memory airChildVoxelTypes = new bytes32[](1);
    airChildVoxelTypes[0] = AirVoxelID;
    CAVoxelTypeDefs.set(AirVoxelID, airChildVoxelTypes);

    bytes32[] memory dirtChildVoxelTypes = new bytes32[](1);
    dirtChildVoxelTypes[0] = DirtVoxelID;
    CAVoxelTypeDefs.set(DirtVoxelID, dirtChildVoxelTypes);

    bytes32[] memory grassChildVoxelTypes = new bytes32[](1);
    grassChildVoxelTypes[0] = GrassVoxelID;
    CAVoxelTypeDefs.set(GrassVoxelID, grassChildVoxelTypes);
  }

  function isVoxelTypeAllowed(bytes32 voxelTypeId) public pure returns (bool) {
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
        CAVoxelType.get(callerAddress, existingEntity).voxelTypeId == AirVoxelID,
        "This position is already occupied by another voxel"
      );
    } else {
      // TODO: Add terrain gen checks
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    }

    bytes32 voxelVariantId = updateVoxelVariant(voxelTypeId, entity);
    CAVoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId);
  }

  function updateVoxelVariant(bytes32 voxelTypeId, bytes32 entity) public returns (bytes32) {
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
    bytes32 parentEntity
  ) public returns (bytes32[] memory changedEntities) {
    // loop over all neighbours and run interaction logic
    // the interaction's used will can be in different namespaces
    // can change type at position
    // keep looping until no more type and position changes
  }
}
