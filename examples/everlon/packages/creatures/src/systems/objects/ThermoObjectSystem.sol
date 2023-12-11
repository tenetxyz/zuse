// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-creatures/src/codegen/world/IWorld.sol";
import { ObjectType } from "@tenet-base-world/src/prototypes/ObjectType.sol";

import { Thermo, ThermoData } from "@tenet-creatures/src/codegen/tables/Thermo.sol";

import { registerObjectType } from "@tenet-registry/src/Utils.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord, getObjectType } from "@tenet-base-world/src/Utils.sol";

import { calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { VoxelCoord, ObjectProperties, Action, ActionType, SimTable, BlockDirection } from "@tenet-utils/src/Types.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { DirtObjectID } from "@tenet-world/src/Constants.sol";

import { entityIsThermo } from "@tenet-creatures/src/Utils.sol";
import { REGISTRY_ADDRESS, ThermoObjectID } from "@tenet-creatures/src/Constants.sol";

contract ThermoObjectSystem is ObjectType {
  function registerObject() public {
    address world = _world();
    registerObjectType(
      REGISTRY_ADDRESS,
      ThermoObjectID,
      world,
      IWorld(world).creatures_ThermoObjectSyst_enterWorld.selector,
      IWorld(world).creatures_ThermoObjectSyst_exitWorld.selector,
      IWorld(world).creatures_ThermoObjectSyst_eventHandler.selector,
      IWorld(world).creatures_ThermoObjectSyst_neighbourEventHandler.selector,
      "Thermo",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    address worldAddress = _msgSender();
    ObjectProperties memory objectProperties;
    objectProperties.mass = 10;

    Thermo.set(worldAddress, objectEntityId, ThermoData({ lastInteractionBlock: 0, hasValue: true }));

    return objectProperties;
  }

  function exitWorld(bytes32 objectEntityId, VoxelCoord memory coord) public override {
    address worldAddress = _msgSender();
    Thermo.deleteRecord(worldAddress, objectEntityId);
  }

  function eventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (Action[] memory) {
    address worldAddress = _msgSender();
    uint256 lastInteractionBlock = Thermo.getLastInteractionBlock(worldAddress, centerObjectEntityId);
    if (block.number == lastInteractionBlock) {
      return new Action[](0);
    }
    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, centerObjectEntityId);
    VoxelCoord memory coord = getVoxelCoord(IStore(worldAddress), centerObjectEntityId);
    if (entityProperties.energy > 0) {
      // We convert all our general energy to temperature energy
      return getTemperatureConversionActions(centerObjectEntityId, coord, entityProperties);
    }

    uint256 temperatureTransferAmount = 0;
    {
      uint256 validThermoNeighbours = calculateValidThermoNeighbours(
        worldAddress,
        neighbourObjectEntityIds,
        entityProperties
      );
      if (validThermoNeighbours > 0) {
        temperatureTransferAmount = getTemperatureToThermo(entityProperties.temperature) / validThermoNeighbours;
      }
    }

    Action[] memory actions = new Action[](neighbourObjectEntityIds.length);
    for (uint256 i = 0; i < neighbourObjectEntityIds.length; i++) {
      if (uint256(neighbourObjectEntityIds[i]) == 0) {
        continue;
      }
      VoxelCoord memory neighbourCoord = getVoxelCoord(IStore(worldAddress), neighbourObjectEntityIds[i]);
      if (entityIsThermo(worldAddress, neighbourObjectEntityIds[i])) {
        ObjectProperties memory neighbourEntityProperties = getObjectProperties(
          worldAddress,
          neighbourObjectEntityIds[i]
        );
        // This will allow temperature to flow from the hotter cell to the colder cells
        if (temperatureTransferAmount > 0 && neighbourEntityProperties.temperature < entityProperties.temperature) {
          actions[i] = Action({
            actionType: ActionType.Transfer,
            senderTable: SimTable.Temperature,
            senderValue: abi.encode(uint256ToNegativeInt256(temperatureTransferAmount)),
            targetObjectEntityId: neighbourObjectEntityIds[i],
            targetCoord: neighbourCoord,
            targetTable: SimTable.Temperature,
            targetValue: abi.encode(uint256ToInt256(temperatureTransferAmount))
          });
          entityProperties.temperature -= temperatureTransferAmount;
        }
      } else if (
        entityProperties.temperature > 0 &&
        getObjectType(IStore(worldAddress), neighbourObjectEntityIds[i]) == DirtObjectID &&
        calculateBlockDirection(coord, neighbourCoord) == BlockDirection.Up
      ) {
        // launch a fireball
        VoxelCoord memory launchCoord = neighbourCoord;

        // Parabolic trajectory
        VoxelCoord[] memory launchTrajectory = new VoxelCoord[](4);
        launchTrajectory[0] = VoxelCoord({ x: launchCoord.x, y: launchCoord.y + 1, z: launchCoord.z + 1 });
        launchTrajectory[1] = VoxelCoord({ x: launchCoord.x, y: launchCoord.y + 2, z: launchCoord.z + 2 });
        launchTrajectory[2] = VoxelCoord({ x: launchCoord.x, y: launchCoord.y + 1, z: launchCoord.z + 3 });
        launchTrajectory[3] = VoxelCoord({ x: launchCoord.x, y: launchCoord.y, z: launchCoord.z + 4 });

        actions[i] = Action({
          actionType: ActionType.Transfer,
          senderTable: SimTable.Temperature,
          senderValue: abi.encode(uint256ToNegativeInt256(entityProperties.temperature)),
          targetObjectEntityId: neighbourObjectEntityIds[i],
          targetCoord: neighbourCoord,
          targetTable: SimTable.Velocity,
          targetValue: abi.encode(launchTrajectory)
        });
      }
    }

    Thermo.setLastInteractionBlock(worldAddress, centerObjectEntityId, block.number);

    return new Action[](0);
  }

  function getTemperatureConversionActions(
    bytes32 centerObjectEntityId,
    VoxelCoord memory coord,
    ObjectProperties memory entityProperties
  ) internal pure returns (Action[] memory) {
    Action[] memory conversionActions = new Action[](1);
    conversionActions[0] = Action({
      actionType: ActionType.Transformation,
      senderTable: SimTable.Energy,
      senderValue: abi.encode(uint256ToNegativeInt256(entityProperties.energy)),
      targetObjectEntityId: centerObjectEntityId,
      targetCoord: coord,
      targetTable: SimTable.Temperature,
      targetValue: abi.encode(uint256ToInt256(entityProperties.energy))
    });
    return conversionActions;
  }

  function calculateValidThermoNeighbours(
    address worldAddress,
    bytes32[] memory neighbourObjectEntityIds,
    ObjectProperties memory entityProperties
  ) internal view returns (uint256 numValidThermoNeighbours) {
    for (uint256 i = 0; i < neighbourObjectEntityIds.length; i++) {
      if (uint256(neighbourObjectEntityIds[i]) == 0) {
        continue;
      }

      if (
        entityIsThermo(worldAddress, neighbourObjectEntityIds[i]) &&
        getObjectProperties(worldAddress, neighbourObjectEntityIds[i]).temperature < entityProperties.temperature
      ) {
        numValidThermoNeighbours += 1;
      }
    }
    return numValidThermoNeighbours;
  }

  function getTemperatureToThermo(uint256 temperature) internal pure returns (uint256) {
    return (temperature * 60) / 100; // Transfer 60% of its temperature to neighbouring thermo cells
  }

  function neighbourEventHandler(
    bytes32 neighbourObjectEntityId,
    bytes32 centerObjectEntityId
  ) public override returns (bool, Action[] memory) {
    address worldAddress = _msgSender();
    uint256 lastInteractionBlock = Thermo.getLastInteractionBlock(worldAddress, neighbourObjectEntityId);
    if (block.number == lastInteractionBlock) {
      return (false, new Action[](0));
    }

    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, neighbourObjectEntityId);
    VoxelCoord memory coord = getVoxelCoord(IStore(worldAddress), neighbourObjectEntityId);
    if (entityProperties.energy > 0) {
      // We convert all our general energy to temperature energy
      // Note: The bool return value is false as we don't request an event here, since the action
      // will trigger an event anyways. It would just lead to duplicate events.
      return (false, getTemperatureConversionActions(neighbourObjectEntityId, coord, entityProperties));
    }

    VoxelCoord memory centerCoord = getVoxelCoord(IStore(worldAddress), centerObjectEntityId);
    if (
      (getTemperatureToThermo(entityProperties.temperature) > 0 &&
        entityIsThermo(worldAddress, centerObjectEntityId) &&
        getObjectProperties(worldAddress, centerObjectEntityId).temperature < entityProperties.temperature) ||
      (entityProperties.temperature > 0 &&
        getObjectType(IStore(worldAddress), centerObjectEntityId) == DirtObjectID &&
        calculateBlockDirection(coord, getVoxelCoord(IStore(worldAddress), centerObjectEntityId)) == BlockDirection.Up)
    ) {
      return (true, new Action[](0));
    }

    return (false, new Action[](0));
  }
}
