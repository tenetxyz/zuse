// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";
import { AirVoxelID, ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract InitSystem is System {
  function registerCA() public {
    bytes32[] memory caVoxelTypes = new bytes32[](2);
    caVoxelTypes[0] = AirVoxelID;
    caVoxelTypes[1] = ElectronVoxelID;

    safeCall(
      REGISTRY_ADDRESS,
      abi.encodeWithSignature(REGISTER_CA_SIG, "Base CA", "Has electrons", caVoxelTypes),
      "registerCA"
    );
  }
}
