// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { CAMind } from "@tenet-base-ca/src/codegen/tables/CAMind.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { VoxelType, VoxelTypeData, VoxelTypeTableId } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { WorldConfig } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { getCAMindSelector, setCAMindSelector } from "@tenet-base-ca/src/CallUtils.sol";

abstract contract MindSystem is System {
  function setMindSelector(VoxelEntity memory entity, bytes4 mindSelector) public virtual {
    require(
      VoxelType.getHasValue(entity.scale, entity.entityId),
      "setMindSelector: Entity does not exist"
    );
    bytes32 voxelTypeId = VoxelType.getVoxelTypeId(entity.scale, entity.entityId);
    address caAddress = WorldConfig.get(voxelTypeId);
    setCAMindSelector(caAddress, entity.entityId, mindSelector);
  }
}
