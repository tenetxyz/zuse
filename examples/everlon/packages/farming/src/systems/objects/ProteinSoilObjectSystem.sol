// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-farming/src/codegen/world/IWorld.sol";
import { ObjectType } from "@tenet-base-world/src/prototypes/ObjectType.sol";
import { IObjectRegistrySystem } from "@tenet-registry/src/codegen/world/IObjectRegistrySystem.sol";

import { Soil, SoilData } from "@tenet-farming/src/codegen/tables/Soil.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";

import { VoxelCoord, ObjectProperties, Action, ActionType, SimTable } from "@tenet-utils/src/Types.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";

import { SoilType } from "@tenet-farming/src/codegen/Types.sol";
import { entityIsSoil, entityIsPlant, getNutrientConversionActions, isValidPlantNeighbour } from "@tenet-farming/src/Utils.sol";
import { REGISTRY_ADDRESS, ProteinSoilObjectID, SOIL_MASS } from "@tenet-farming/src/Constants.sol";

contract ProteinSoilObjectSystem is ObjectType {
  function registerObject() public {
    address world = _world();
    IObjectRegistrySystem(REGISTRY_ADDRESS).registerObjectType(
      ProteinSoilObjectID,
      world,
      IWorld(world).farming_ProteinSoilObjec_enterWorld.selector,
      IWorld(world).farming_ProteinSoilObjec_exitWorld.selector,
      IWorld(world).farming_ProteinSoilObjec_eventHandler.selector,
      IWorld(world).farming_ProteinSoilObjec_neighbourEventHandler.selector,
      "Protein Soil",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    address worldAddress = _msgSender();
    ObjectProperties memory objectProperties;
    objectProperties.mass = SOIL_MASS;

    // Init NPK values
    objectProperties.nitrogen = 98;
    objectProperties.phosphorus = 1;
    objectProperties.potassium = 1;

    Soil.set(
      worldAddress,
      objectEntityId,
      SoilData({ lastInteractionBlock: 0, soilType: SoilType.Protein, hasValue: true })
    );
    return objectProperties;
  }

  function exitWorld(bytes32 objectEntityId, VoxelCoord memory coord) public override {
    address worldAddress = _msgSender();
    Soil.deleteRecord(worldAddress, objectEntityId);
  }

  function eventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (Action[] memory) {
    address worldAddress = _msgSender();
    uint256 lastInteractionBlock = Soil.getLastInteractionBlock(worldAddress, centerObjectEntityId);
    if (block.number == lastInteractionBlock) {
      return new Action[](0);
    }
    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, centerObjectEntityId);
    VoxelCoord memory coord = getVoxelCoord(IStore(worldAddress), centerObjectEntityId);
    if (entityProperties.energy > 0) {
      // We convert all our general energy to nutrient energy
      return getNutrientConversionActions(centerObjectEntityId, coord, entityProperties);
    }

    Action[] memory actions = new Action[](neighbourObjectEntityIds.length);
    for (uint256 i = 0; i < neighbourObjectEntityIds.length; i++) {
      if (uint256(neighbourObjectEntityIds[i]) == 0) {
        continue;
      }
      VoxelCoord memory neighbourCoord = getVoxelCoord(IStore(worldAddress), neighbourObjectEntityIds[i]);
      if (entityIsSoil(worldAddress, neighbourObjectEntityIds[i])) {
        ObjectProperties memory neighbourEntityProperties = getObjectProperties(
          worldAddress,
          neighbourObjectEntityIds[i]
        );
        if (entityProperties.phosphorus > 0 && neighbourEntityProperties.phosphorus < entityProperties.phosphorus) {
          // Transfer out any phosphorus we have in excess
          actions[i] = Action({
            actionType: ActionType.Transfer,
            senderTable: SimTable.Phosphorus,
            senderValue: abi.encode(uint256ToNegativeInt256(entityProperties.phosphorus)),
            targetObjectEntityId: neighbourObjectEntityIds[i],
            targetCoord: neighbourCoord,
            targetTable: SimTable.Phosphorus,
            targetValue: abi.encode(uint256ToInt256(entityProperties.phosphorus))
          });
          entityProperties.phosphorus = 0;
        }
      } else if (isValidPlantNeighbour(worldAddress, coord, neighbourObjectEntityIds[i], neighbourCoord)) {
        if (entityProperties.nutrients > 0) {
          uint256 proteinTransferAmount = entityProperties.nutrients; // Convert all nutrients to protein

          actions[i] = Action({
            actionType: ActionType.Transfer,
            senderTable: SimTable.Nutrients,
            senderValue: abi.encode(uint256ToNegativeInt256(proteinTransferAmount)),
            targetObjectEntityId: neighbourObjectEntityIds[i],
            targetCoord: neighbourCoord,
            targetTable: SimTable.Protein,
            targetValue: abi.encode(uint256ToInt256(proteinTransferAmount))
          });

          entityProperties.nutrients = 0;
        }
      }
    }

    Soil.setLastInteractionBlock(worldAddress, centerObjectEntityId, block.number);

    return actions;
  }

  function neighbourEventHandler(
    bytes32 neighbourObjectEntityId,
    bytes32 centerObjectEntityId
  ) public override returns (bool, Action[] memory) {
    address worldAddress = _msgSender();
    uint256 lastInteractionBlock = Soil.getLastInteractionBlock(worldAddress, neighbourObjectEntityId);
    if (block.number == lastInteractionBlock) {
      return (false, new Action[](0));
    }

    ObjectProperties memory entityProperties = getObjectProperties(worldAddress, neighbourObjectEntityId);
    VoxelCoord memory coord = getVoxelCoord(IStore(worldAddress), neighbourObjectEntityId);
    if (entityProperties.energy > 0) {
      // We convert all our general energy to nutrient energy
      // Note: The bool return value is false as we don't request an event here, since the action
      // will trigger an event anyways. It would just lead to duplicate events.
      return (false, getNutrientConversionActions(neighbourObjectEntityId, coord, entityProperties));
    }

    VoxelCoord memory centerCoord = getVoxelCoord(IStore(worldAddress), centerObjectEntityId);
    if (
      entityIsSoil(worldAddress, centerObjectEntityId) ||
      isValidPlantNeighbour(worldAddress, coord, centerObjectEntityId, centerCoord)
    ) {
      return (true, new Action[](0));
    }

    return (false, new Action[](0));
  }
}
