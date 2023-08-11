// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { BuildEvent } from "../prototypes/BuildEvent.sol";
import { VoxelCoord } from "../Types.sol";
import { OwnedBy, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";

contract BuildSystem is BuildEvent {
  function callEventHandler(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent
  ) internal override returns (uint32, bytes32) {
    return IWorld(_world()).buildVoxelType(voxelTypeId, coord, runEventOnChildren, runEventOnParent);
  }

  // Called by users
  function build(uint32 scale, bytes32 entity, VoxelCoord memory coord) public override returns (uint32, bytes32) {
    // Require voxel to be owned by caller
    require(OwnedBy.get(scale, entity) == tx.origin, "voxel is not owned by player");
    VoxelTypeData memory voxelType = VoxelType.get(scale, entity);

    return super.runEvent(voxelType.voxelTypeId, coord);
  }

  // Called by CA
  function buildVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool buildChildren,
    bool buildParent
  ) public override returns (uint32, bytes32) {
    return super.buildVoxelType(voxelTypeId, coord, buildChildren, buildParent);
  }
}
