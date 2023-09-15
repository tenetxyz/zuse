// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { BuildEvent } from "@tenet-base-world/src/prototypes/BuildEvent.sol";
import { BuildEventData } from "@tenet-base-world/src/Types.sol";
import { OwnedBy, VoxelType } from "@tenet-world/src/codegen/Tables.sol";
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

  function callEventHandler(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal override returns (VoxelEntity memory) {
    return IWorld(_world()).buildVoxelType(voxelTypeId, coord, runEventOnChildren, runEventOnParent, eventData);
  }

  // Called by users
  function buildVoxel(
    uint32 scale,
    bytes32 entity,
    VoxelCoord memory coord,
    bytes4 mindSelector
  ) public returns (VoxelEntity memory) {
    // Require voxel to be owned by caller
    require(OwnedBy.get(scale, entity) == tx.origin, "voxel is not owned by player");
    VoxelTypeData memory voxelType = VoxelType.get(scale, entity);

    return super.runEvent(voxelType.voxelTypeId, coord, abi.encode(BuildEventData({ mindSelector: mindSelector })));
  }

  function build(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes4 mindSelector
  ) public override returns (VoxelEntity memory) {
    // TODO: add permission check on ownership
    return super.runEvent(voxelTypeId, coord, abi.encode(BuildEventData({ mindSelector: mindSelector })));
  }

  // Called by CA
  function buildVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool buildChildren,
    bool buildParent,
    bytes memory eventData
  ) public override returns (VoxelEntity memory) {
    return super.buildVoxelType(voxelTypeId, coord, buildChildren, buildParent, eventData);
  }
}