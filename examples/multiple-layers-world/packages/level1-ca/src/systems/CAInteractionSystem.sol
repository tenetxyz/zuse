// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { CAInteraction } from "@tenet-base-ca/src/prototypes/CAInteraction.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";

contract CAInteractionSystem is CAInteraction {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function callGetVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bytes32) {
    return IWorld(_world()).getVoxelVariant(voxelTypeId, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity);
  }

  function runInteraction(
    bytes4 interactionSelector,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32[] memory, bytes[] memory) {
    return super.runInteraction(interactionSelector, interactEntity, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
