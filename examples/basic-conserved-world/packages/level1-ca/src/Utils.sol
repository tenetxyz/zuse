// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { callOrRevert, staticCallOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { caEntityToEntity, caEntityToEntity, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId, CAEntityReverseMappingData } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { VoxelEntity, VoxelCoord, BodySimData, CAEventData, CAEventType, SimEventData, SimTable } from "@tenet-utils/src/Types.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { console } from "forge-std/console.sol";

function getEntitySimData(bytes32 caEntity) view returns (BodySimData memory) {
  CAEntityReverseMappingData memory entityData = CAEntityReverseMapping.get(caEntity);
  VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: entityData.entity });
  bytes memory returnData = staticCallOrRevert(
    entityData.callerAddress,
    abi.encodeWithSignature("getEntitySimData((uint32,bytes32))", entity),
    "getEntitySimData"
  );
  return abi.decode(returnData, (BodySimData));
}

function transferSimData(
  SimTable fromTable,
  SimTable toTable,
  BodySimData memory entitySimData,
  bytes32 targetCAEntity,
  VoxelCoord memory targetCoord,
  uint256 amountToTransfer
) view returns (SimEventData memory) {
  VoxelEntity memory targetEntity = VoxelEntity({ scale: 1, entityId: caEntityToEntity(targetCAEntity) });
  // console.logBytes32(targetEntity.entityId);
  SimEventData memory eventData = SimEventData({
    senderTable: fromTable,
    senderValue: abi.encode(uint256ToNegativeInt256(amountToTransfer)),
    targetEntity: targetEntity,
    targetCoord: targetCoord,
    targetTable: toTable,
    targetValue: abi.encode(uint256ToInt256(amountToTransfer))
  });
  return eventData;
}

function transfer(
  SimTable fromTable,
  SimTable toTable,
  BodySimData memory entitySimData,
  bytes32 targetCAEntity,
  VoxelCoord memory targetCoord,
  uint256 amountToTransfer
) view returns (CAEventData memory) {
  SimEventData memory eventData = transferSimData(
    fromTable,
    toTable,
    entitySimData,
    targetCAEntity,
    targetCoord,
    amountToTransfer
  );
  return CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(eventData) });
}

function stopEvent(
  bytes32 entityId,
  VoxelCoord memory coord,
  BodySimData memory entitySimData
) view returns (bytes memory) {
  VoxelCoord memory velocity = abi.decode(entitySimData.velocity, (VoxelCoord));
  if (velocity.x == 0 && velocity.y == 0 && velocity.z == 0) {
    return new bytes(0);
  }

  // Decrease velocity to 0
  CAEventData[] memory allCAEventData = new CAEventData[](1);
  uint256 transferStamina = 0; // TODO: calculate and don't send event if we dont have enough stamina
  VoxelCoord memory deltaVelocity = VoxelCoord({
    x: velocity.x > 0 ? -velocity.x : velocity.x,
    y: velocity.y > 0 ? -velocity.y : velocity.y,
    z: velocity.z > 0 ? -velocity.z : velocity.z
  });
  SimEventData memory stopEventData = SimEventData({
    senderTable: SimTable.Stamina,
    senderValue: abi.encode(uint256ToInt256(transferStamina)),
    targetEntity: VoxelEntity({ scale: 1, entityId: caEntityToEntity(entityId) }),
    targetCoord: coord,
    targetTable: SimTable.Velocity,
    targetValue: abi.encode(deltaVelocity)
  });
  allCAEventData[0] = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(stopEventData) });
  return abi.encode(allCAEventData);
}
