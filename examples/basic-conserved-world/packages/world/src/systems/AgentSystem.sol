// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelType, OwnedBy, OwnedByTableId } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelEntity, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { getEntityPositionStrict } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS } from "../Constants.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { getInteractionSelectors } from "@tenet-registry/src/Utils.sol";

contract AgentSystem is System {
  function claimAgent(VoxelEntity memory agentEntity) public {
    // Make sure entity has position
    getEntityPositionStrict(agentEntity);

    // Make sure entity has no owner
    require(
      !hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(agentEntity.scale, agentEntity.entityId)),
      "Agent already owned"
    );

    // Make sure entity is an agent
    bytes32 voxelTypeId = VoxelType.getVoxelTypeId(agentEntity.scale, agentEntity.entityId);
    InteractionSelector[] memory interactionSelectors = getInteractionSelectors(IStore(REGISTRY_ADDRESS), voxelTypeId);
    require(interactionSelectors.length > 1, "Not an agent");

    // Claim agent
    OwnedBy.set(agentEntity.scale, agentEntity.entityId, tx.origin);
  }
}
