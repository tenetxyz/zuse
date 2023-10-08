// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { caEntityToEntity } from "@tenet-base-ca/src/Utils.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId, CAEntityReverseMappingData } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { VoxelEntity, VoxelCoord, BodySimData, CAEventData, CAEventType, SimEventData, SimTable } from "@tenet-utils/src/Types.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
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

function getEntitySimData(bytes32 caEntity) view returns (BodySimData memory) {
  console.log("getEntitySimData");
  console.logBytes32(caEntity);
  CAEntityReverseMappingData memory entityData = CAEntityReverseMapping.get(caEntity);
  console.logBytes32(entityData.entity);
  VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: entityData.entity });
  bytes memory returnData = safeStaticCall(
    entityData.callerAddress,
    abi.encodeWithSignature("getEntitySimData((uint32,bytes32))", entity),
    "getEntitySimData"
  );
  return abi.decode(returnData, (BodySimData));
}

function transferEnergy(
  BodySimData memory senderBodyPhysics,
  bytes32 targetCAEntity,
  VoxelCoord memory targetCoord,
  uint256 energyToTransfer
) view returns (CAEventData memory) {
  CAEntityReverseMappingData memory entityData = CAEntityReverseMapping.get(targetCAEntity);
  VoxelEntity memory targetEntity = VoxelEntity({ scale: 1, entityId: entityData.entity });
  SimEventData memory eventData = SimEventData({
    senderTable: SimTable.Energy,
    senderValue: abi.encode(uint256ToNegativeInt256(energyToTransfer)),
    targetEntity: targetEntity,
    targetCoord: targetCoord,
    targetTable: SimTable.Energy,
    targetValue: abi.encode(uint256ToInt256(energyToTransfer))
  });
  return CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(eventData) });
}
