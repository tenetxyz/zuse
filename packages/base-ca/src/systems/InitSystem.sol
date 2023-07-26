// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@base-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_WORLD } from "../Constants.sol";
import { AirVoxelID, DirtVoxelID, GrassVoxelID, BedrockVoxelID } from "@base-ca/src/Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract InitSystem is System {
  function registerCA() public {
    bytes32[] memory caVoxelTypes = new bytes32[](4);
    caVoxelTypes[0] = AirVoxelID;
    caVoxelTypes[1] = DirtVoxelID;
    caVoxelTypes[2] = GrassVoxelID;
    caVoxelTypes[3] = BedrockVoxelID;

    safeCall(
      REGISTRY_WORLD,
      abi.encodeWithSignature(REGISTER_CA_SIG, "Base World", "Has base blocks", caVoxelTypes),
      "registerCA"
    );
  }
}
