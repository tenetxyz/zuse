// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@level3-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";
import { Level3AirVoxelID, RoadVoxelID } from "@level3-ca/src/Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract InitSystem is System {
  function registerCA() public {
    bytes32[] memory caVoxelTypes = new bytes32[](2);
    caVoxelTypes[0] = Level3AirVoxelID;
    caVoxelTypes[1] = RoadVoxelID;

    safeCall(
      REGISTRY_ADDRESS,
      abi.encodeWithSignature(REGISTER_CA_SIG, "Level 3 CA", "Has road", caVoxelTypes),
      "registerCA"
    );
  }
}
