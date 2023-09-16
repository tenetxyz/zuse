// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { BuildEvent } from "@tenet-base-world/src/prototypes/BuildEvent.sol";
import { BuildEventData } from "@tenet-base-world/src/Types.sol";
import { VoxelType } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";

contract BuildSystem is BuildEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function emptyVoxelId() internal pure override returns (bytes32) {
    return AirVoxelID;
  }

  // Called by users
  function build(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes4 mindSelector
  ) public returns (VoxelEntity memory) {
    return
      build(
        voxelTypeId,
        coord,
        abi.encode(BuildEventData({ mindSelector: mindSelector, worldData: abi.encode(bytes32(0)) }))
      );
  }
}
