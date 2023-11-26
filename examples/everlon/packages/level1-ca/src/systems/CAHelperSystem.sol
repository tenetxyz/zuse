// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { CAHelper } from "@tenet-base-ca/src/prototypes/CAHelper.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";

contract CAHelperSystem is CAHelper {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function voxelEnterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) public override {
    super.voxelEnterWorld(voxelTypeId, coord, caEntity);
  }

  function getVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32) {
    return super.getVoxelVariant(voxelTypeId, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity);
  }

  function voxelExitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) public override {
    super.voxelExitWorld(voxelTypeId, coord, caEntity);
  }
}
