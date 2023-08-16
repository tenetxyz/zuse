// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { MindType } from "@tenet-base-ca/src/prototypes/MindType.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { registerMindIntoRegistry } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, FighterVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { Mind } from "@tenet-utils/src/Types.sol";

contract FighterMindSystem is MindType {
  function registerMind() public override {
    registerMindIntoRegistry(
      REGISTRY_ADDRESS,
      FighterVoxelID,
      Mind({
        creator: tx.origin,
        name: "Fighter",
        description: "Fighter Mind",
        mindSelector: IWorld(_world()).ca_FighterMindSyste_mindLogic.selector
      })
    );
  }

  function mindLogic(
    bytes32 bodyTypeId,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes4) {
    return 0;
  }
}
