// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { NamespaceOwner } from "@latticexyz/world/src/tables/NamespaceOwner.sol";
import { FunctionSelectors } from "@latticexyz/world/src/modules/core/tables/FunctionSelectors.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelTypesAllowed } from "@tenet-contracts/src/codegen/Tables.sol";
import { getCallerNamespace } from "../Utils.sol";
import { AirID } from "./voxels/AirVoxelSystem.sol";
import { GrassID } from "./voxels/GrassVoxelSystem.sol";
import { DirtID } from "./voxels/DirtVoxelSystem.sol";
import { BedrockID } from "./voxels/BedrockVoxelSystem.sol";

contract VoxelRegistrySystem is System {
  function initWorldVoxelTypes() public {
    bytes32[] memory allowedVoxelTypes = new bytes32[](4);
    allowedVoxelTypes[0] = AirID;
    allowedVoxelTypes[1] = GrassID;
    allowedVoxelTypes[2] = DirtID;
    allowedVoxelTypes[3] = BedrockID;
    VoxelTypesAllowed.set(allowedVoxelTypes);
  }

  function isVoxelTypeAllowed(bytes32 voxelTypeId) public returns (bool) {
    bytes32[] memory allVoxelTypeIds = VoxelTypesAllowed.get();
    for (uint256 i = 0; i < allVoxelTypeIds.length; i++) {
      if (allVoxelTypeIds[i] == voxelTypeId) {
        return true;
      }
    }
    return false;
  }
}
