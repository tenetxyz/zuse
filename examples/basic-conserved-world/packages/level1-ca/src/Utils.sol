// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId, CAEntityReverseMappingData } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { VoxelEntity, VoxelCoord, BodyPhysicsData, CAEventData, CAEventType } from "@tenet-utils/src/Types.sol";
import { console } from "forge-std/console.sol";

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

function transferEnergy(VoxelCoord memory targetCoord, uint256 targetAmount) pure returns (CAEventData memory) {
  VoxelCoord[] memory newCoords = new VoxelCoord[](1);
  newCoords[0] = targetCoord;
  uint256[] memory energyFluxAmounts = new uint256[](1);
  energyFluxAmounts[0] = targetAmount;
  return
    CAEventData({
      eventType: CAEventType.FluxEnergy,
      newCoords: newCoords,
      energyFluxAmounts: energyFluxAmounts,
      massFluxAmount: 0
    });
}
