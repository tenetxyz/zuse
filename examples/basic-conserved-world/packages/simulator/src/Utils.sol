// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";

function getVelocity(address callerAddress, VoxelEntity memory entity) view returns (VoxelCoord memory) {
  bytes memory velocity = Velocity.getVelocity(callerAddress, entity.scale, entity.entityId);
  return abi.decode(velocity, (VoxelCoord));
}

function getTerrainMass(address callerAddress, uint32 scale, VoxelCoord memory coord) view returns (uint256) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getTerrainMass(uint32,(int32,int32,int32))", scale, coord),
    string(abi.encode("getTerrainMass ", callerAddress, " ", scale, " ", coord))
  );
  return abi.decode(returnData, (uint256));
}

function getTerrainEnergy(address callerAddress, uint32 scale, VoxelCoord memory coord) view returns (uint256) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getTerrainEnergy(uint32,(int32,int32,int32))", scale, coord),
    string(abi.encode("getTerrainEnergy ", callerAddress, " ", scale, " ", coord))
  );
  return abi.decode(returnData, (uint256));
}

function getTerrainVelocity(
  address callerAddress,
  uint32 scale,
  VoxelCoord memory coord
) view returns (VoxelCoord memory) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getTerrainVelocity(uint32,(int32,int32,int32))", scale, coord),
    string(abi.encode("getTerrainVelocity ", callerAddress, " ", scale, " ", coord))
  );
  return abi.decode(returnData, (VoxelCoord));
}

function getMooreNeighbourEntities(
  address callerAddress,
  VoxelEntity memory entity,
  uint8 neighbourRadius
) view returns (bytes32[] memory, VoxelCoord[] memory) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("calculateMooreNeighbourEntities((uint32,bytes32),uint8)", entity, neighbourRadius),
    string(abi.encode("calculateMooreNeighbourEntities ", callerAddress, " ", entity, " ", neighbourRadius))
  );
  return abi.decode(returnData, (bytes32[], VoxelCoord[]));
}

function getNeighbourEntities(
  address callerAddress,
  VoxelEntity memory entity
) view returns (bytes32[] memory, VoxelCoord[] memory) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("calculateNeighbourEntities((uint32,bytes32))", entity),
    string(abi.encode("calculateNeighbourEntities ", callerAddress, " ", entity))
  );
  return abi.decode(returnData, (bytes32[], VoxelCoord[]));
}

function createTerrainEntity(
  address callerAddress,
  uint32 scale,
  VoxelCoord memory terrainCoord
) returns (VoxelEntity memory) {
  bytes memory returnData = safeCall(
    callerAddress,
    abi.encodeWithSignature("createTerrainEntity(uint32,(int32,int32,int32))", scale, terrainCoord),
    string(abi.encode("createTerrainEntity ", callerAddress, " ", scale, " ", terrainCoord))
  );
  return abi.decode(returnData, (VoxelEntity));
}

function getVoxelCoordStrict(address callerAddress, VoxelEntity memory entity) view returns (VoxelCoord memory) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getVoxelCoordStrict((uint32,bytes32))", entity),
    string(abi.encode("getVoxelCoordStrict ", callerAddress, " ", entity))
  );
  return abi.decode(returnData, (VoxelCoord));
}

function getEntityAtCoord(address callerAddress, uint32 scale, VoxelCoord memory coord) view returns (bytes32) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getEntityAtCoord(uint32,(int32,int32,int32))", scale, coord),
    string(abi.encode("getEntityAtCoord ", callerAddress, " ", scale, " ", coord))
  );
  return abi.decode(returnData, (bytes32));
}

function getVoxelTypeId(address callerAddress, VoxelEntity memory entity) view returns (bytes32) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getVoxelTypeId((uint32,bytes32))", entity),
    string(abi.encode("getVoxelTypeId ", callerAddress, " ", entity))
  );
  return abi.decode(returnData, (bytes32));
}
