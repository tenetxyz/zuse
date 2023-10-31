// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { callOrRevert, staticCallOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { caEntityToEntity, caEntityToEntity } from "@tenet-base-ca/src/Utils.sol";
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
  console.logBytes32(targetEntity.entityId);
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
