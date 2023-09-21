// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId, CAEntityReverseMappingData } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { VoxelEntity, BodyPhysicsData } from "@tenet-utils/src/Types.sol";

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
