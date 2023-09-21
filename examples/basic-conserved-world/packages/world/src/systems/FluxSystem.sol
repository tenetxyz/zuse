// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { FluxEvent } from "@tenet-world/src/prototypes/FluxEvent.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { ActivateEventData } from "@tenet-base-world/src/Types.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { BodyPhysics, BodyPhysicsData } from "@tenet-world/src/codegen/tables/BodyPhysics.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { distanceBetween } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { FluxEventData } from "@tenet-world/src/Types.sol";

contract FluxSystem is FluxEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function processCAEvents(EntityEventData[] memory entitiesEventData) internal override {
    IWorld(_world()).caEventsHandler(entitiesEventData);
  }

  // Called by users
  function fluxEnergyOut(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint256 energyToFlux,
    VoxelCoord memory energyReceiver
  ) public returns (VoxelEntity memory) {
    FluxEventData memory fluxEventData = FluxEventData({
      massToFlux: 0,
      energyToFlux: energyToFlux,
      energyReceiver: energyReceiver
    });
    return flux(voxelTypeId, coord, abi.encode(fluxEventData));
  }

  function fluxMass(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint256 massToFlux
  ) public returns (VoxelEntity memory) {
    FluxEventData memory fluxEventData;
    fluxEventData.massToFlux = massToFlux;
    return flux(voxelTypeId, coord, abi.encode(fluxEventData));
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    // Check and do flux
    FluxEventData memory fluxEventData = abi.decode(eventData, (FluxEventData));
    BodyPhysicsData memory bodyPhysicsData = BodyPhysics.get(eventVoxelEntity.scale, eventVoxelEntity.entityId);
    if (fluxEventData.massToFlux > 0) {
      // We're fluxing mass out
      // Check if the entity has this mass
      require(bodyPhysicsData.mass >= fluxEventData.massToFlux, "FluxEvent: not enough mass to flux");
      // Update the mass of the entity
      uint256 newMass = bodyPhysicsData.mass - fluxEventData.massToFlux;
      if (newMass == 0) {
        IWorld(_world()).mineWithAgent(voxelTypeId, coord, eventVoxelEntity);
      } else {
        // Calculate how much energy this operation requires
        uint256 energyRequired = fluxEventData.massToFlux * 10;
        IWorld(_world()).fluxEnergy(false, caAddress, eventVoxelEntity, energyRequired);
        BodyPhysics.setMass(eventVoxelEntity.scale, eventVoxelEntity.entityId, newMass);
      }
    } else if (fluxEventData.energyToFlux > 0) {
      // We're fluxing energy out to in the direction of the receiver
      // Check if the entity has this energy
      require(bodyPhysicsData.energy >= fluxEventData.energyToFlux, "FluxEvent: not enough energy to flux");
      VoxelCoord memory energyReceiverCoord = fluxEventData.energyReceiver;
      require(distanceBetween(coord, energyReceiverCoord) == 1, "Energy can only be fluxed to a surrounding neighbour");

      bytes32 energyReceiverEntityId = getEntityAtCoord(eventVoxelEntity.scale, energyReceiverCoord);
      VoxelEntity memory energyReceiverEntity = VoxelEntity({
        entityId: energyReceiverEntityId,
        scale: eventVoxelEntity.scale
      });
      if (uint256(energyReceiverEntityId) == 0) {
        (bytes32 terrainVoxelTypeId, BodyPhysicsData memory terrainPhysicsData) = IWorld(_world())
          .getTerrainBodyPhysicsData(caAddress, energyReceiverCoord);
        energyReceiverEntity = IWorld(_world()).spawnBody(
          terrainVoxelTypeId,
          energyReceiverCoord,
          bytes4(0),
          terrainPhysicsData
        );
      }
      // Increase energy of energyReceiverEntity
      uint256 newReceiverEnergy = BodyPhysics.getEnergy(energyReceiverEntity.scale, energyReceiverEntity.entityId) +
        fluxEventData.energyToFlux;
      BodyPhysics.setEnergy(energyReceiverEntity.scale, energyReceiverEntity.entityId, newReceiverEnergy);
      // Decrease energy of eventEntity
      uint256 newEnergy = bodyPhysicsData.energy - fluxEventData.energyToFlux;
      BodyPhysics.setEnergy(eventVoxelEntity.scale, eventVoxelEntity.entityId, newEnergy);
    }
  }
}
