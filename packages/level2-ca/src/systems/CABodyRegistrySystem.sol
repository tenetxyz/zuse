// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CABodyRegistry } from "@tenet-base-ca/src/prototypes/CABodyRegistry.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";

contract CABodyRegistrySystem is CABodyRegistry {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function registerBodyType(bytes32 bodyTypeId) public override {
    return super.registerBodyType(bodyTypeId);
  }
}
