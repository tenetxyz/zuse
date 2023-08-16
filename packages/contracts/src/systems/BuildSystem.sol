// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { BuildEvent } from "../prototypes/BuildEvent.sol";
import { VoxelCoord, BuildEventData } from "../Types.sol";
import { OwnedBy, BodyType, BodyTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";

contract BuildSystem is BuildEvent {
  function callEventHandler(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal override returns (uint32, bytes32) {
    return IWorld(_world()).buildBodyType(bodyTypeId, coord, runEventOnChildren, runEventOnParent, eventData);
  }

  // Called by users
  function build(
    uint32 scale,
    bytes32 entity,
    VoxelCoord memory coord,
    bytes4 mindSelector
  ) public override returns (uint32, bytes32) {
    // Require voxel to be owned by caller
    require(OwnedBy.get(scale, entity) == tx.origin, "voxel is not owned by player");
    BodyTypeData memory bodyType = BodyType.get(scale, entity);

    return super.runEvent(bodyType.bodyTypeId, coord, abi.encode(BuildEventData({ mindSelector: mindSelector })));
  }

  // Called by CA
  function buildBodyType(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool buildChildren,
    bool buildParent,
    bytes memory eventData
  ) public override returns (uint32, bytes32) {
    return super.buildBodyType(bodyTypeId, coord, buildChildren, buildParent, eventData);
  }
}
