// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { ObjectProperties } from "@tenet-utils/src/Types.sol";
import { staticCallOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { WORLD_GET_OBJECT_PROPERTIES_SIG } from "@tenet-base-world/src/Constants.sol";

function getObjectProperties(address worldAddress, bytes32 objectEntityId) view returns (ObjectProperties memory) {
  bytes memory returnData = staticCallOrRevert(
    worldAddress,
    abi.encodeWithSignature(WORLD_GET_OBJECT_PROPERTIES_SIG, objectEntityId),
    "getObjectProperties"
  );
  return abi.decode(returnData, (ObjectProperties));
}
