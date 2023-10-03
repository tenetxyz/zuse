// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { FluxEvent } from "@tenet-world/src/prototypes/FluxEvent.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { ActivateEventData } from "@tenet-base-world/src/Types.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { distanceBetween } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { FluxEventData } from "@tenet-world/src/Types.sol";
import { console } from "forge-std/console.sol";
import { MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH } from "@tenet-utils/src/Constants.sol";
import { massChange, energyTransfer } from "@tenet-simulator/src/CallUtils.sol";

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
    uint256[] memory energyToFlux,
    VoxelCoord[] memory energyReceiver
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
    if (fluxEventData.massToFlux > 0) {
      // Update the mass of the entity
      uint256 newMass = Mass.get(IStore(SIMULATOR_ADDRESS), _world(), eventVoxelEntity.entityId) -
        fluxEventData.massToFlux;
      if (newMass == 0) {
        IWorld(_world()).mineWithAgent(voxelTypeId, coord, eventVoxelEntity);
      } else {
        massChange(SIMULATOR_ADDRESS, eventVoxelEntity, coord, newMass);
      }
    } else if (fluxEventData.energyToFlux.length > 0) {
      require(fluxEventData.energyToFlux.length == fluxEventData.energyReceiver.length, "FluxEvent: invalid data");
      for (uint i = 0; i < fluxEventData.energyToFlux.length; i++) {
        if (fluxEventData.energyToFlux[i] == 0) {
          continue;
        }
        // We're fluxing energy out to in the direction of the receiver
        // Check if the entity has this energy
        VoxelCoord memory energyReceiverCoord = fluxEventData.energyReceiver[i];
        bytes32 energyReceiverEntityId = getEntityAtCoord(eventVoxelEntity.scale, energyReceiverCoord);
        VoxelEntity memory energyReceiverEntity = VoxelEntity({
          scale: eventVoxelEntity.scale,
          entityId: energyReceiverEntityId
        });
        energyTransfer(
          SIMULATOR_ADDRESS,
          eventVoxelEntity,
          coord,
          energyReceiverEntity,
          energyReceiverCoord,
          fluxEventData.energyToFlux[i]
        );
      }
    }
  }

  function runCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal override returns (EntityEventData[] memory) {
    FluxEventData memory fluxEventData = abi.decode(eventData, (FluxEventData));
    // TODO: Optimize the length of this array
    EntityEventData[] memory allEntitiesEventData = new EntityEventData[](
      MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH * fluxEventData.energyToFlux.length
    );
    uint allEntitiesEventDataIdx = 0;
    if (fluxEventData.energyToFlux.length > 0) {
      for (uint i = 0; i < fluxEventData.energyToFlux.length; i++) {
        if (fluxEventData.energyToFlux[i] == 0) {
          continue;
        }
        VoxelCoord memory energyReceiverCoord = fluxEventData.energyReceiver[i];
        bytes32 energyReceiverEntityId = getEntityAtCoord(eventVoxelEntity.scale, energyReceiverCoord);
        VoxelEntity memory energyReceiverEntity = VoxelEntity({
          scale: eventVoxelEntity.scale,
          entityId: energyReceiverEntityId
        });
        EntityEventData[] memory entitiesEventData = IWorld(_world()).runCA(caAddress, energyReceiverEntity, bytes4(0));
        for (uint j = 0; j < entitiesEventData.length; j++) {
          if (entitiesEventData[j].eventData.length > 0) {
            allEntitiesEventData[allEntitiesEventDataIdx] = entitiesEventData[j];
            allEntitiesEventDataIdx++;
          }
        }
      }
    }
    return allEntitiesEventData;
  }
}
