// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { VoxelEntity, BlockDirection, BodySimData, CAEventData, CAEventType, SimEventData, SimTable, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToNegativeInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId, CAEntityReverseMappingData } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { Plant, PlantData } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { Thermo } from "@tenet-pokemon-extension/src/codegen/tables/Thermo.sol";
import { PlantStage, EventType } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon, entityIsFarmer, entityIsThermo } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict, caEntityToEntity } from "@tenet-base-ca/src/Utils.sol";
import { Farmer } from "@tenet-pokemon-extension/src/codegen/tables/Farmer.sol";
import { getEntitySimData, transfer, transferSimData } from "@tenet-level1-ca/src/Utils.sol";
import { DirtVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { PlantConsumer } from "@tenet-pokemon-extension/src/Types.sol";

contract ThermoSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId,
    BlockDirection centerBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    console.log("onNewNeighbour thermo");
    console.logBytes32(neighbourEntityId);
    uint256 lastInteractionBlock = Thermo.getLastInteractionBlock(callerAddress, neighbourEntityId);
    if (block.number == lastInteractionBlock) {
      return (changedEntity, entityData);
    }

    BodySimData memory entitySimData = getEntitySimData(neighbourEntityId);
    if (entitySimData.energy > 0) {
      // We convert all our general energy to nutrient energy
      entityData = getTemperatureConversion(callerAddress, neighbourEntityId, entitySimData);
      return (changedEntity, entityData);
    }

    if (Thermo.getLastEvent(callerAddress, neighbourEntityId) != EventType.None) {
      Thermo.setLastEvent(callerAddress, neighbourEntityId, EventType.None);
    }

    uint256 transferToThermo = getTemperatureToThermo(entitySimData.temperature);
    console.log("transferToThermo");
    console.logUint(entitySimData.temperature);
    console.logUint(transferToThermo);
    if (transferToThermo == 0) {
      return (changedEntity, entityData);
    }
    console.log("checking");
    if (
      !((getCAVoxelType(centerEntityId) == DirtVoxelID && centerBlockDirection == BlockDirection.Down) ||
        (entityIsThermo(callerAddress, centerEntityId) &&
          getEntitySimData(centerEntityId).temperature <= entitySimData.temperature))
    ) {
      return (changedEntity, entityData);
    }
    console.log("changed true");

    changedEntity = true;

    return (changedEntity, entityData);
  }

  function calculateValidThermoNeighbours(
    address callerAddress,
    bytes32[] memory neighbourEntityIds,
    BodySimData memory entitySimData
  ) internal view returns (uint256 numThermoNeighbours) {
    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      // Check if the neighbor is a Soil, Seed, or Young Plant cell
      if (
        entityIsThermo(callerAddress, neighbourEntityIds[i]) &&
        getEntitySimData(neighbourEntityIds[i]).temperature <= entitySimData.temperature
      ) {
        numThermoNeighbours += 1;
      }
    }
    return numThermoNeighbours;
  }

  function getTemperatureToThermo(uint256 temperature) internal pure returns (uint256) {
    return (temperature * 60) / 100; // Transfer 60% of its temperature to neighbouring thermo cells
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    console.log("runInteraction thermo");
    console.logBytes32(interactEntity);
    {
      uint256 lastInteractionBlock = Thermo.getLastInteractionBlock(callerAddress, interactEntity);
      if (block.number == lastInteractionBlock) {
        return (changedEntity, entityData);
      }
    }
    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    if (entitySimData.energy > 0) {
      // We convert all our general energy to temperature energy
      entityData = getTemperatureConversion(callerAddress, interactEntity, entitySimData);
      return (changedEntity, entityData);
    }

    if (Thermo.getLastEvent(callerAddress, interactEntity) != EventType.None) {
      Thermo.setLastEvent(callerAddress, interactEntity, EventType.None);
    }

    (bool hasTransfer, CAEventData[] memory allCAEventData) = runMainLogic(
      callerAddress,
      entitySimData,
      neighbourEntityIds,
      neighbourEntityDirections
    );

    // Check if there's at least one transfer
    if (hasTransfer) {
      Thermo.setLastInteractionBlock(callerAddress, interactEntity, block.number);
    }
    entityData = abi.encode(allCAEventData);

    return (changedEntity, entityData);
  }

  function runMainLogic(
    address callerAddress,
    BodySimData memory entitySimData,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections
  ) internal returns (bool, CAEventData[] memory) {
    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);
    uint256 transferPerThermo = 0;
    {
      uint256 validThermoNeighbours = calculateValidThermoNeighbours(callerAddress, neighbourEntityIds, entitySimData);
      if (validThermoNeighbours > 0) {
        transferPerThermo = getTemperatureToThermo(entitySimData.temperature) / validThermoNeighbours;
      }
    }

    bool hasTransfer = false;
    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (
        entityIsThermo(callerAddress, neighbourEntityIds[i]) &&
        getEntitySimData(neighbourEntityIds[i]).temperature <= entitySimData.temperature
      ) {
        if (transferPerThermo > 0) {
          console.log("transfer");
          console.logBytes32(neighbourEntityIds[i]);
          console.log("transferPerThermo");
          console.logUint(transferPerThermo);
          allCAEventData[i] = transfer(
            SimTable.Temperature,
            SimTable.Temperature,
            entitySimData,
            neighbourEntityIds[i],
            getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]),
            transferPerThermo
          );
          hasTransfer = true;
        }
      } else if (
        getCAVoxelType(neighbourEntityIds[i]) == DirtVoxelID && neighbourEntityDirections[i] == BlockDirection.Down
      ) {
        if (entitySimData.temperature == 0) {
          continue;
        }
        // launch it!
        VoxelCoord memory launchCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);

        // Parabolic trajectory
        VoxelCoord[] memory launchTrajectory = new VoxelCoord[](4);
        launchTrajectory[0] = VoxelCoord({ x: launchCoord.x, y: launchCoord.y + 1, z: launchCoord.z + 1 });
        launchTrajectory[1] = VoxelCoord({ x: launchCoord.x, y: launchCoord.y + 2, z: launchCoord.z + 2 });
        launchTrajectory[2] = VoxelCoord({ x: launchCoord.x, y: launchCoord.y + 1, z: launchCoord.z + 3 });
        launchTrajectory[3] = VoxelCoord({ x: launchCoord.x, y: launchCoord.y, z: launchCoord.z + 4 });

        SimEventData memory launchEventData = SimEventData({
          senderTable: SimTable.Temperature,
          senderValue: abi.encode(uint256ToInt256(entitySimData.temperature)),
          targetEntity: VoxelEntity({ scale: 1, entityId: caEntityToEntity(neighbourEntityIds[i]) }),
          targetCoord: launchCoord,
          targetTable: SimTable.Velocity,
          targetValue: abi.encode(launchTrajectory)
        });
        allCAEventData[i] = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(launchEventData) });
        hasTransfer = true;
      }
    }
    return (hasTransfer, allCAEventData);
  }

  function getTemperatureConversion(
    address callerAddress,
    bytes32 interactEntity,
    BodySimData memory entitySimData
  ) internal returns (bytes memory) {
    EventType lastEventType = Thermo.getLastEvent(callerAddress, interactEntity);

    if (entitySimData.energy > 0 && lastEventType != EventType.SetTemperature) {
      CAEventData[] memory allCAEventData = new CAEventData[](1);
      VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);
      console.log("converting");
      console.logUint(entitySimData.energy);
      allCAEventData[0] = transfer(
        SimTable.Energy,
        SimTable.Temperature,
        entitySimData,
        interactEntity,
        coord,
        entitySimData.energy
      );
      Thermo.setLastEvent(callerAddress, interactEntity, EventType.SetTemperature);
      return abi.encode(allCAEventData);
    }

    return new bytes(0);
  }

  function eventHandlerThermo(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }

  function neighbourEventHandlerThermo(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public returns (bool, bytes memory) {
    return super.neighbourEventHandler(callerAddress, neighbourEntityId, centerEntityId);
  }
}
