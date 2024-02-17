// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { AgentAction, AgentActionData } from "@tenet-world/src/codegen/tables/AgentAction.sol";

import { ObjectType, Faucet, FaucetData, FaucetTableId } from "@tenet-world/src/codegen/Tables.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";

import { inSurroundingCube } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityIdFromObjectEntityId, getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";

contract AgentActionSystem is System {
  function hit(bytes32 agentObjectEntityId, bytes32 targetObjectEntityId, uint32 damage) public {
    require(
      hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(agentObjectEntityId)),
      "AgentActionSystem: entity has no owner"
    );
    require(OwnedBy.get(agentObjectEntityId) == _msgSender(), "AgentActionSystem: caller does not own entity");
    AgentAction.set(agentObjectEntityId, true, targetObjectEntityId, damage);

    // TODO: Figure out how to forward caller to world

    // TODO: Compute these client side instead
    // bytes32 agentEntityId = getEntityIdFromObjectEntityId(IStore(_world()), agentObjectEntityId);
    // VoxelCoord memory agentCoord = getVoxelCoordStrict(IStore(_world()), agentEntityId);
    // bytes32 activateObjectTypeId = ObjectType.get(agentEntityId);
    // IWorld(_world()).activate(agentObjectEntityId, activateObjectTypeId, agentCoord);
  }

  function clearAction(bytes32 agentObjectEntityId) public {
    require(
      hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(agentObjectEntityId)),
      "AgentActionSystem: entity has no owner"
    );
    require(OwnedBy.get(agentObjectEntityId) == _msgSender(), "AgentActionSystem: caller does not own entity");
    AgentAction.deleteRecord(agentObjectEntityId);
  }
}
