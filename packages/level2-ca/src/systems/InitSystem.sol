// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { REGISTER_CA_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { CAVoxelConfigTableId } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract InitSystem is System {
  function registerCA() public {
    bytes32[][] memory caVoxelTypeKeys = getKeysInTable(CAVoxelConfigTableId);
    bytes32[] memory caVoxelTypes = new bytes32[](caVoxelTypeKeys.length);
    for (uint i = 0; i < caVoxelTypeKeys.length; i++) {
      caVoxelTypes[i] = caVoxelTypeKeys[i][0];
    }

    safeCall(
      REGISTRY_ADDRESS,
      abi.encodeWithSignature(REGISTER_CA_SIG, "Level 2 CA", "Has road and signal", caVoxelTypes),
      "registerCA"
    );
  }
}
