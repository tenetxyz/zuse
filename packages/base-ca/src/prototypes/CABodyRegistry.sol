// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ADD_BODY_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

abstract contract CABodyRegistry is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function registerBodyType(bytes32 bodyTypeId) public virtual {
    // Update registry
    safeCall(getRegistryAddress(), abi.encodeWithSignature(ADD_BODY_CA_SIG, bodyTypeId), "addBodyToCA");
  }
}
