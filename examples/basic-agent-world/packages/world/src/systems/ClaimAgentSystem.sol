// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-world/src/codegen/tables/OwnedBy.sol";
import { getEntityPositionStrict } from "@tenet-base-world/src/Utils.sol";

contract ClaimAgentSystem is System {
  function claimAgent(VoxelEntity memory agentEntity) public {
    // Make sure entity has position
    getEntityPositionStrict(agentEntity);

    // Make sure entity has no owner
    require(
      !hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(agentEntity.scale, agentEntity.entityId)),
      "Agent already owned"
    );

    // Claim agent
    OwnedBy.set(agentEntity.scale, agentEntity.entityId, _msgSender());
  }
}
