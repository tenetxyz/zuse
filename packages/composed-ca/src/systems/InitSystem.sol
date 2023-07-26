// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@composed-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_WORLD } from "../Constants.sol";
import { Level2AirVoxelID, RoadVoxelID } from "@composed-ca/src/Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract InitSystem is System {
  function registerCA() public {
    bytes32[] memory caVoxelTypes = new bytes32[](2);
    caVoxelTypes[0] = Level2AirVoxelID;
    caVoxelTypes[1] = RoadVoxelID;

    safeCall(
      REGISTRY_WORLD,
      abi.encodeWithSignature(REGISTER_CA_SIG, "Level 2 World", "Has road", caVoxelTypes),
      "registerCA"
    );
  }
}
