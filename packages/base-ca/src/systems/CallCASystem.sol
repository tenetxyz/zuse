// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { CAVoxelConfig, CAVoxelConfigTableId } from "@tenet-base-ca/src/codegen/Tables.sol";
import { getCallerNamespace } from "@tenet-utils/src/Utils.sol";

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
}
