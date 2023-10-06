// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId, CAEntityReverseMappingData } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { VoxelEntity, VoxelCoord, BodyPhysicsData, SimEventData, SimTable } from "@tenet-utils/src/Types.sol";
import { console } from "forge-std/console.sol";
import { SHARD_DIM } from "@tenet-level1-ca/src/Constants.sol";

function floorDiv(int32 a, int32 b) pure returns (int32) {
  require(b != 0, "Division by zero");
  if (a >= 0) {
    return a / b;
  } else {
    int32 result = a / b;
    return (a % b != 0) ? result - 1 : result;
  }
}

function coordToShardCoord(VoxelCoord memory coord) pure returns (VoxelCoord memory) {
  return
    VoxelCoord({ x: floorDiv(coord.x, SHARD_DIM), y: floorDiv(coord.y, SHARD_DIM), z: floorDiv(coord.z, SHARD_DIM) });
}

function shardCoordToCoord(VoxelCoord memory coord) pure returns (VoxelCoord memory) {
  return VoxelCoord({ x: coord.x * SHARD_DIM, y: coord.y * SHARD_DIM, z: coord.z * SHARD_DIM });
}

function getVoxelBodyPhysicsFromCaller(bytes32 caEntity) view returns (BodyPhysicsData memory) {
  CAEntityReverseMappingData memory entityData = CAEntityReverseMapping.get(caEntity);
  VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: entityData.entity });
  bytes memory returnData = safeStaticCall(
    entityData.callerAddress,
    abi.encodeWithSignature("getEntityBodyPhysics((uint32,bytes32))", entity),
    "getEntityBodyPhysics"
  );
  return abi.decode(returnData, (BodyPhysicsData));
}

function transferEnergy(
  BodyPhysicsData memory senderBodyPhysics,
  bytes32 targetCAEntity,
  VoxelCoord memory targetCoord,
  uint256 energyToTransfer
) view returns (SimEventData memory) {
  console.log("transferEnergy called");
  console.logUint(energyToTransfer);
  console.logUint(senderBodyPhysics.energy);
  CAEntityReverseMappingData memory entityData = CAEntityReverseMapping.get(targetCAEntity);
  VoxelEntity memory targetEntity = VoxelEntity({ scale: 1, entityId: entityData.entity });
  bytes memory returnData = safeStaticCall(
    entityData.callerAddress,
    abi.encodeWithSignature("getEntityEnergy((uint32,bytes32))", targetEntity),
    "getEntityEnergy"
  );
  uint256 currentTargetEnergy = abi.decode(returnData, (uint256));
  uint256 targetAmount = currentTargetEnergy + energyToTransfer;
  console.log("return bro");
  return
    SimEventData({
      senderTable: SimTable.Energy,
      senderValue: abi.encode(senderBodyPhysics.energy),
      targetEntity: targetEntity,
      targetCoord: targetCoord,
      targetTable: SimTable.Energy,
      targetValue: abi.encode(targetAmount)
    });
}
