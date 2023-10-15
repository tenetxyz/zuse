// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelEntity } from "@tenet-utils/src/Types.sol";
import { MindSystem as MindSystemPrototype } from "@tenet-base-world/src/prototypes/MindSystem.sol";

contract MindSystem is MindSystemPrototype {
  function setMindSelector(VoxelEntity memory entity, bytes4 mindSelector) public override {
    super.setMindSelector(entity, mindSelector);
  }
}
