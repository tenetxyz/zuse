// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-farming/src/codegen/world/IWorld.sol";
import { ObjectType } from "@tenet-base-world/src/prototypes/ObjectType.sol";

import { Plant, PlantData } from "@tenet-farming/src/codegen/tables/Plant.sol";
import { Farmer } from "@tenet-farming/src/codegen/tables/Farmer.sol";

import { registerObjectType } from "@tenet-registry/src/Utils.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";

import { VoxelCoord, ObjectProperties, Action, ActionType, SimTable } from "@tenet-utils/src/Types.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";

import { entityIsSoil, entityIsPlant, entityIsFarmer, getNutrientConversionActions, isValidPlantNeighbour } from "@tenet-farming/src/Utils.sol";
import { REGISTRY_ADDRESS, PlantObjectID } from "@tenet-farming/src/Constants.sol";
import { PlantConsumer } from "@tenet-farming/src/Types.sol";

contract PlantObjectSystem is ObjectType {
  function registerObject() public {
    address world = _world();
    registerObjectType(
      REGISTRY_ADDRESS,
      PlantObjectID,
      world,
      IWorld(world).farming_PlantObjectSyste_enterWorld.selector,
      IWorld(world).farming_PlantObjectSyste_exitWorld.selector,
      IWorld(world).farming_PlantObjectSyste_eventHandler.selector,
      IWorld(world).farming_PlantObjectSyste_neighbourEventHandler.selector,
      "Plant",
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

    // Init NPK values
    objectProperties.nitrogen = 30;
    objectProperties.phosphorus = 30;
    objectProperties.potassium = 30;

    PlantConsumer[] memory consumers = new PlantConsumer[](0);
    Plant.set(
      worldAddress,
      objectEntityId,
      PlantData({ lastInteractionBlock: 0, totalProduced: 0, consumers: abi.encode(consumers), hasValue: true })
    );
    return objectProperties;
  }

  function exitWorld(bytes32 objectEntityId, VoxelCoord memory coord) public override {
    address worldAddress = _msgSender();
    Plant.deleteRecord(worldAddress, objectEntityId);
  }

  function eventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (Action[] memory) {
    address worldAddress = _msgSender();
    updateTotalProduced(worldAddress, centerObjectEntityId);
    PlantData memory plantData = Plant.get(worldAddress, centerObjectEntityId);
    if (block.number == plantData.lastInteractionBlock) {
      return new Action[](0);
    }
    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, centerObjectEntityId);
    VoxelCoord memory coord = getVoxelCoord(IStore(worldAddress), centerObjectEntityId);

    uint256 elixirTransferAmount;
    uint256 proteinTransferAmount;
    {
      // Transfer 100% of its food to its consumers
      (uint harvestPlantElixir, uint harvestPlantProtein) = (entityProperties.elixir, entityProperties.protein);
      if (harvestPlantElixir == 0 && harvestPlantProtein == 0) {
        return new Action[](0);
      }
      // Divide it equally among all consumers
      uint256 numConsumingNeighbours = calculateConsumingNeighbours(worldAddress, neighbourObjectEntityIds);
      if (numConsumingNeighbours == 0) {
        return new Action[](0);
      }
      elixirTransferAmount = harvestPlantElixir / numConsumingNeighbours;
      proteinTransferAmount = harvestPlantProtein / numConsumingNeighbours;
      if (numConsumingNeighbours > 0) {
        plantData.lastInteractionBlock = block.number;
      }
    }

    Action[] memory actions = new Action[](neighbourObjectEntityIds.length * 2);

    for (uint256 i = 0; i < neighbourObjectEntityIds.length; i++) {
      if (uint256(neighbourObjectEntityIds[i]) == 0) {
        continue;
      }

      ObjectProperties memory neighbourEntityProperties = getObjectProperties(
        worldAddress,
        neighbourObjectEntityIds[i]
      );
      VoxelCoord memory neighbourCoord = getVoxelCoord(IStore(worldAddress), neighbourObjectEntityIds[i]);
      // Special case for farmer, where we check if it's hungry
      if (entityIsFarmer(worldAddress, neighbourObjectEntityIds[i])) {
        if (Farmer.getIsHungry(worldAddress, neighbourObjectEntityIds[i])) {
          (actions[i * 2], actions[i * 2 + 1], plantData) = getConsumerActions(
            neighbourObjectEntityIds[i],
            neighbourCoord,
            elixirTransferAmount,
            proteinTransferAmount,
            plantData
          );
        }
      } else if (neighbourEntityProperties.hasHealth || neighbourEntityProperties.hasStamina) {
        (actions[i * 2], actions[i * 2 + 1], plantData) = getConsumerActions(
          neighbourObjectEntityIds[i],
          neighbourCoord,
          elixirTransferAmount,
          proteinTransferAmount,
          plantData
        );
      }
    }

    Plant.set(worldAddress, centerObjectEntityId, plantData);

    return actions;
  }

  function calculateConsumingNeighbours(
    address worldAddress,
    bytes32[] memory neighbourObjectEntityIds
  ) internal view returns (uint256 numConsumingNeighbours) {
    for (uint256 i = 0; i < neighbourObjectEntityIds.length; i++) {
      if (uint256(neighbourObjectEntityIds[i]) == 0) {
        continue;
      }
      ObjectProperties memory neighbourEntityProperties = getObjectProperties(
        worldAddress,
        neighbourObjectEntityIds[i]
      );
      // Special case for farmer, where we check if it's hungry
      if (entityIsFarmer(worldAddress, neighbourObjectEntityIds[i])) {
        if (Farmer.getIsHungry(worldAddress, neighbourObjectEntityIds[i])) {
          numConsumingNeighbours += 1;
        }
      } else if (neighbourEntityProperties.hasHealth || neighbourEntityProperties.hasStamina) {
        numConsumingNeighbours += 1;
      }
    }
    return numConsumingNeighbours;
  }

  function addPlantConsumer(
    PlantData memory plantData,
    bytes32 consumerObjectEntityId
  ) internal returns (PlantData memory) {
    PlantConsumer[] memory currentConsumers = abi.decode(plantData.consumers, (PlantConsumer[]));
    PlantConsumer[] memory newConsumers = new PlantConsumer[](currentConsumers.length + 1);
    for (uint i = 0; i < currentConsumers.length; i++) {
      newConsumers[i] = currentConsumers[i];
    }
    newConsumers[currentConsumers.length] = PlantConsumer({
      objectEntityId: consumerObjectEntityId,
      consumedBlockNumber: block.number
    });
    plantData.consumers = abi.encode(newConsumers);
    return plantData;
  }

  // TODO: Find a more efficient way to do this
  function updateTotalProduced(address worldAddress, bytes32 objectEntityId) internal {
    uint256 totalProduced = Plant.getTotalProduced(worldAddress, objectEntityId);
    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, objectEntityId);
    // TOOD: we need to add totalConsumed since these were still produced by the plant
    uint256 currentProduced = entityProperties.elixir + entityProperties.protein;
    if (currentProduced > totalProduced) {
      Plant.setTotalProduced(worldAddress, objectEntityId, currentProduced);
    }
  }

  function getConsumerActions(
    bytes32 neighbourObjectEntityId,
    VoxelCoord memory neighbourCoord,
    uint256 elixirTransferAmount,
    uint256 proteinTransferAmount,
    PlantData memory plantData
  ) internal returns (Action memory, Action memory, PlantData memory) {
    Action memory elixirTransferAction;
    Action memory proteinTransferAction;
    if (elixirTransferAmount > 0) {
      elixirTransferAction = Action({
        actionType: ActionType.Transfer,
        senderTable: SimTable.Elixir,
        senderValue: abi.encode(uint256ToNegativeInt256(elixirTransferAmount)),
        targetObjectEntityId: neighbourObjectEntityId,
        targetCoord: neighbourCoord,
        targetTable: SimTable.Health,
        targetValue: abi.encode(uint256ToInt256(elixirTransferAmount))
      });
    }
    if (proteinTransferAmount > 0) {
      proteinTransferAction = Action({
        actionType: ActionType.Transfer,
        senderTable: SimTable.Protein,
        senderValue: abi.encode(uint256ToNegativeInt256(proteinTransferAmount)),
        targetObjectEntityId: neighbourObjectEntityId,
        targetCoord: neighbourCoord,
        targetTable: SimTable.Stamina,
        targetValue: abi.encode(uint256ToInt256(proteinTransferAmount))
      });
    }

    if (elixirTransferAmount > 0 || proteinTransferAmount > 0) {
      plantData = addPlantConsumer(plantData, neighbourObjectEntityId);
    }

    return (elixirTransferAction, proteinTransferAction, plantData);
  }

  function neighbourEventHandler(
    bytes32 neighbourObjectEntityId,
    bytes32 centerObjectEntityId
  ) public override returns (bool, Action[] memory) {
    address worldAddress = _msgSender();
    updateTotalProduced(worldAddress, centerObjectEntityId);
    uint256 lastInteractionBlock = Plant.getLastInteractionBlock(worldAddress, neighbourObjectEntityId);
    if (block.number == lastInteractionBlock) {
      return (false, new Action[](0));
    }

    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, neighbourObjectEntityId);
    // Transfer 100% of its food to its consumers
    (uint harvestPlantElixir, uint harvestPlantProtein) = (entityProperties.elixir, entityProperties.protein);
    if (harvestPlantElixir == 0 && harvestPlantProtein == 0) {
      return (false, new Action[](0));
    }

    ObjectProperties memory centerEntityProperties = getObjectProperties(worldAddress, centerObjectEntityId);
    // Special case for farmer, where we check if it's hungry
    if (entityIsFarmer(worldAddress, centerObjectEntityId)) {
      if (Farmer.getIsHungry(worldAddress, centerObjectEntityId)) {
        return (true, new Action[](0));
      }
    } else if (centerEntityProperties.hasHealth || centerEntityProperties.hasStamina) {
      return (true, new Action[](0));
    }

    return (false, new Action[](0));
  }
}
