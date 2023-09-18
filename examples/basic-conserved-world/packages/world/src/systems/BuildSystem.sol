// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { BuildEvent } from "@tenet-base-world/src/prototypes/BuildEvent.sol";
import { BuildEventData } from "@tenet-base-world/src/Types.sol";
import { OwnedBy, VoxelType, VoxelTypeProperties, BodyPhysics } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BuildWorldEventData } from "@tenet-world/src/Types.sol";

contract BuildSystem is BuildEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
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

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal override {
    // Update the mass of the entity to be the type definition's mass
    uint256 bodyMass = VoxelTypeProperties.get(voxelTypeId);
    BodyPhysics.setMass(eventVoxelEntity.scale, eventVoxelEntity.entityId, bodyMass);
    // Calculate how much energy this operation requires
    uint256 energyToDissipate = bodyMass * 100;
    // Go through all the neighbours and equally take from each one, up till a maximum threshold for this level
    // if it runs out, go to the next set of neighbours, another radius away
    uint8 radius = 1;
    while (energyToDissipate > 0) {
      bytes32[] memory useNeighbourEntities = IWorld(_world()).calculateMooreNeighbourEntities(
        eventVoxelEntity,
        radius
      );
      radius += 1;
    }

    // level = 1
    // while energy > 0 {
    // get neighbours at level 1
    // need to take from each negihbour, up to maximum threshold for this layer
    // should take more from ones with higher gravity
    //
  }
}
