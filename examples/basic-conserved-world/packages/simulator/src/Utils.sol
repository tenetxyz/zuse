// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";

function getVelocity(address callerAddress, bytes32 entityId) view returns (VoxelCoord memory) {
  bytes memory velocity = Velocity.getVelocity(callerAddress, entityId);
  return abi.decode(velocity, (VoxelCoord));
}

function getTerrainMass(address callerAddress, VoxelCoord memory coord) view returns (uint256) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getTerrainMass(uint32,(int32,int32,int32))", 1, coord),
    string(abi.encode("getTerrainMass ", callerAddress, " ", coord))
  );
  return abi.decode(returnData, (uint256));
}

function getTerrainEnergy(address callerAddress, VoxelCoord memory coord) view returns (uint256) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getTerrainEnergy(uint32,(int32,int32,int32))", 1, coord),
    string(abi.encode("getTerrainEnergy ", callerAddress, " ", coord))
  );
  return abi.decode(returnData, (uint256));
}

function getTerrainVelocity(address callerAddress, VoxelCoord memory coord) view returns (VoxelCoord memory) {
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("getTerrainVelocity(uint32,(int32,int32,int32))", 1, coord),
    string(abi.encode("getTerrainVelocity ", callerAddress, " ", coord))
  );
  return abi.decode(returnData, (VoxelCoord));
}

function getNeighbourEntities(
  address callerAddress,
  bytes32 entityId,
  uint8 neighbourRadius
) view returns (bytes32[] memory, VoxelCoord[] memory) {
  VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: entityId });
  bytes memory returnData = safeStaticCall(
    callerAddress,
    abi.encodeWithSignature("calculateMooreNeighbourEntities((uint32,bytes32),uint8)", entity, neighbourRadius),
    string(abi.encode("calculateMooreNeighbourEntities ", callerAddress, " ", entityId, " ", neighbourRadius))
  );
  return abi.decode(returnData, (bytes32[], VoxelCoord[]));
}

function createTerrainEntity(address callerAddress, VoxelCoord memory terrainCoord) returns (VoxelEntity memory) {
  bytes memory returnData = safeCall(
    callerAddress,
    abi.encodeWithSignature("createTerrainEntity((int32,int32,int32))", terrainCoord),
    string(abi.encode("createTerrainEntity ", callerAddress, " ", terrainCoord))
  );
  return abi.decode(returnData, (VoxelEntity));
}
