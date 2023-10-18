// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord, VoxelEntity, BodySimData } from "@tenet-utils/src/Types.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";

function getEntitySimData(address worldAddress, VoxelEntity memory entity) view returns (BodySimData memory) {
  bytes memory returnData = safeStaticCall(
    worldAddress,
    abi.encodeWithSignature("getEntitySimData((uint32,bytes32))", entity),
    "getEntitySimData"
  );
  return abi.decode(returnData, (BodySimData));
}
