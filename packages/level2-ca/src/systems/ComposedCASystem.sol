// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CAVoxelType, CAVoxelTypeData, CAPosition, CAPositionData, CAPositionTableId } from "@level2-ca/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Level2AirVoxelID, DirtVoxelID, DirtVoxelVariantID, GrassVoxelID, GrassVoxelVariantID, BedrockVoxelID, BedrockVoxelVariantID, SignalVoxelID, SignalOffVoxelVariantID, SignalOnVoxelVariantID } from "@level2-ca/src/Constants.sol";
import { EMPTY_ID } from "./LibTerrainSystem.sol";
import { AirVoxelID, AirVoxelVariantID, ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract ComposedCASystem is System {
  function isVoxelTypeAllowed(bytes32 voxelTypeId) public pure returns (bool) {
    if (
      voxelTypeId == Level2AirVoxelID ||
      voxelTypeId == DirtVoxelID ||
      voxelTypeId == GrassVoxelID ||
      voxelTypeId == BedrockVoxelID ||
      voxelTypeId == SignalVoxelID
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
    } else if (voxelTypeId == DirtVoxelID) {
      return DirtVoxelVariantID;
    } else if (voxelTypeId == GrassVoxelID) {
      return GrassVoxelVariantID;
    } else if (voxelTypeId == BedrockVoxelID) {
      return BedrockVoxelVariantID;
    } else if (voxelTypeId == SignalVoxelID) {
      return SignalOffVoxelVariantID;
    } else {
      revert("This voxel type is not allowed in this CA");
    }
  }

  function exitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
    require(voxelTypeId != Level2AirVoxelID, "can not mine air");
    address callerAddress = _msgSender();
    if (!hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity))) {
      // If there is no entity at this position, try mining the terrain voxel at this position
      bytes32 terrainVoxelTypeId = IWorld(_world()).getTerrainVoxel(coord);
      require(terrainVoxelTypeId != EMPTY_ID && terrainVoxelTypeId == voxelTypeId, "invalid terrain voxel type");
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    }
    // set to Air
    bytes32 airVoxelVariantId = getVoxelVariant(Level2AirVoxelID, entity);
    CAVoxelType.set(callerAddress, entity, Level2AirVoxelID, airVoxelVariantId);
  }

  function signalInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory childEntityIds,
    CAVoxelTypeData memory entityTypeData
  ) public returns (bool changedEntity) {
    bytes32 bottomLeft = childEntityIds[0];
    bytes32 bottomRight = childEntityIds[1];
    bytes32 topLeft = childEntityIds[4];
    bytes32 topRight = childEntityIds[5];

    bytes32 bottomLeftType = AirVoxelID;
    if (bottomLeft != 0) {
      bytes memory returnData = safeCall(
        callerAddress,
        abi.encodeWithSignature("getVoxelTypeId(uint32,bytes32)", 1, bottomLeft),
        "getVoxelTypeId"
      );
      bottomLeftType = abi.decode(returnData, (bytes32));
    }
    bytes32 bottomRightType = AirVoxelID;
    if (bottomRight != 0) {
      bytes memory returnData = safeCall(
        callerAddress,
        abi.encodeWithSignature("getVoxelTypeId(uint32,bytes32)", 1, bottomRight),
        "getVoxelTypeId"
      );
      bottomRightType = abi.decode(returnData, (bytes32));
    }
    bytes32 topLeftType = AirVoxelID;
    if (topLeft != 0) {
      bytes memory returnData = safeCall(
        callerAddress,
        abi.encodeWithSignature("getVoxelTypeId(uint32,bytes32)", 1, topLeft),
        "getVoxelTypeId"
      );
      topLeftType = abi.decode(returnData, (bytes32));
    }
    bytes32 topRightType = AirVoxelID;
    if (topRight != 0) {
      bytes memory returnData = safeCall(
        callerAddress,
        abi.encodeWithSignature("getVoxelTypeId(uint32,bytes32)", 1, topRight),
        "getVoxelTypeId"
      );
      topRightType = abi.decode(returnData, (bytes32));
    }

    if (topLeftType == ElectronVoxelID && bottomRightType == ElectronVoxelID) {
      if (entityTypeData.voxelVariantId != SignalOffVoxelVariantID) {
        CAVoxelType.set(callerAddress, interactEntity, SignalVoxelID, SignalOffVoxelVariantID);
        changedEntity = true;
      }
    } else if (bottomLeftType == ElectronVoxelID && topRightType == ElectronVoxelID) {
      if (entityTypeData.voxelVariantId != SignalOnVoxelVariantID) {
        CAVoxelType.set(callerAddress, interactEntity, SignalVoxelID, SignalOnVoxelVariantID);
        changedEntity = true;
      }
    }
  }

  function runInteraction(
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32[] memory changedEntities) {
    address callerAddress = _msgSender();
    changedEntities = new bytes32[](1);

    CAVoxelTypeData memory entityTypeData = CAVoxelType.get(callerAddress, interactEntity);
    if (entityTypeData.voxelTypeId == SignalVoxelID) {
      // calculate electron positions in childEntityIds
      if (signalInteraction(callerAddress, interactEntity, childEntityIds, entityTypeData)) {
        changedEntities[0] = interactEntity;
      }
    }
  }
}
