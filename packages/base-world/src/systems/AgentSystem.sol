// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";

import { getEntityPositionStrict } from "@tenet-base-world/src/Utils.sol";

abstract contract AgentSystem is System {
  function claimAgent(bytes32 agentEntityId) public virtual {
    // Make sure entity has position
    getEntityPositionStrict(IStore(_world()), agentEntityId);

    // Make sure entity has no owner
    bytes32 agentObjectEntityId = ObjectEntity.get(agentEntityId);
    require(!hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(agentObjectEntityId)), "Agent already owned");

    // Claim agent
    OwnedBy.set(agentObjectEntityId, _msgSender());
  }
}
