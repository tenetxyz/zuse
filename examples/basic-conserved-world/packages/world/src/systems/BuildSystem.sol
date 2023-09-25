// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { BuildEvent } from "@tenet-base-world/src/prototypes/BuildEvent.sol";
import { BuildEventData } from "@tenet-base-world/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { OwnedBy, VoxelType, VoxelTypeProperties, BodyPhysics, BodyPhysicsData, BodyPhysicsTableId, WorldConfig } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { min } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BuildWorldEventData } from "@tenet-world/src/Types.sol";

contract BuildSystem is BuildEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function processCAEvents(EntityEventData[] memory entitiesEventData) internal override {
    IWorld(_world()).caEventsHandler(entitiesEventData);
  }

  function emptyVoxelId() internal pure override returns (bytes32) {
    return AirVoxelID;
  }

  // Called by users
  function buildWithAgent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory agentEntity,
    bytes4 mindSelector
  ) public returns (VoxelEntity memory) {
    BuildWorldEventData memory buildEventData = BuildWorldEventData({ agentEntity: agentEntity });
    return
      build(
        voxelTypeId,
        coord,
        abi.encode(BuildEventData({ mindSelector: mindSelector, worldData: abi.encode(buildEventData) }))
      );
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal override {
    super.preRunCA(caAddress, voxelTypeId, coord, eventVoxelEntity, eventData);
    // Update the mass of the entity to be the type definition's mass
    uint256 bodyMass = VoxelTypeProperties.get(voxelTypeId);
    // Calculate how much energy this operation requires
    uint256 energyRequired = bodyMass * 10;
    IWorld(_world()).fluxEnergy(true, caAddress, eventVoxelEntity, energyRequired);
    BodyPhysicsData memory bodyPhysicsData;
    if (!hasKey(BodyPhysicsTableId, BodyPhysics.encodeKeyTuple(eventVoxelEntity.scale, eventVoxelEntity.entityId))) {
      bodyPhysicsData.mass = bodyMass;
      bodyPhysicsData.energy = 0;
      bodyPhysicsData.velocity = abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }));
    } else {
      bodyPhysicsData = BodyPhysics.get(eventVoxelEntity.scale, eventVoxelEntity.entityId);
      bodyPhysicsData.mass = bodyMass;
    }
    bodyPhysicsData.lastUpdateBlock = block.number;
    BodyPhysics.set(eventVoxelEntity.scale, eventVoxelEntity.entityId, bodyPhysicsData);
  }
}
