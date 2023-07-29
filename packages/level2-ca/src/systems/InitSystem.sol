// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";
import { Level2AirVoxelID, DirtVoxelID, GrassVoxelID, BedrockVoxelID, SignalVoxelID } from "@level2-ca/src/Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract InitSystem is System {
  function registerCA() public {
    bytes32[] memory caVoxelTypes = new bytes32[](5);
    caVoxelTypes[0] = Level2AirVoxelID;
    caVoxelTypes[1] = DirtVoxelID;
    caVoxelTypes[2] = GrassVoxelID;
    caVoxelTypes[3] = BedrockVoxelID;
    caVoxelTypes[4] = SignalVoxelID;

    safeCall(
      REGISTRY_ADDRESS,
      abi.encodeWithSignature(REGISTER_CA_SIG, "Level 2 CA", "Has road and signal", caVoxelTypes),
      "registerCA"
    );
  }
}
