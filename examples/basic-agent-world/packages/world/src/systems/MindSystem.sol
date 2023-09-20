// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelEntity } from "@tenet-utils/src/Types.sol";
import { MindSystem as MindSystemPrototype } from "@tenet-base-world/src/prototypes/MindSystem.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-world/src/codegen/tables/OwnedBy.sol";

contract MindSystem is MindSystemPrototype {
  function getMindSelector(VoxelEntity memory entity) public override returns (bytes4) {
    return super.getMindSelector(entity);
  }

  function setMindSelector(VoxelEntity memory entity, bytes4 mindSelector) public override {
    require(
      hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(entity.scale, entity.entityId)),
      "MindSystem: entity has no owner"
    );
    require(OwnedBy.get(entity.scale, entity.entityId) == _msgSender(), "MindSystem: caller does not own entity");
    super.setMindSelector(entity, mindSelector);
  }
}
