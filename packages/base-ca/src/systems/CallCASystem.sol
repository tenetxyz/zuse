// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { CAVoxelConfig, CAVoxelConfigTableId } from "@tenet-base-ca/src/codegen/Tables.sol";
import { getCallerNamespace } from "@tenet-utils/src/Utils.sol";
import { buildWorld, mineWorld } from "@tenet-base-ca/src/CallUtils.sol";

contract CallCASystem is System {
  function registerInitialVoxelType(
    bytes32 voxelTypeId,
    bytes4 enterWorldSelector,
    bytes4 exitWorldSelector,
    bytes4 voxelVariantSelector,
    bytes4 activateSelector,
    bytes4 interactionSelector
  ) public {
    require(
      !hasKey(CAVoxelConfigTableId, CAVoxelConfig.encodeKeyTuple(voxelTypeId)),
      "Voxel type has already been registered for this CA"
    );

    CAVoxelConfig.set(
      voxelTypeId,
      enterWorldSelector,
      exitWorldSelector,
      voxelVariantSelector,
      activateSelector,
      interactionSelector
    );
  }

  function buildCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) public {
    buildWorld(callerAddress, voxelTypeId, coord);
  }

  function mineCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) public {
    mineWorld(callerAddress, voxelTypeId, coord);
  }
}
