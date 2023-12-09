// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-farming/src/codegen/world/IWorld.sol";
import { ObjectType } from "@tenet-base-world/src/prototypes/ObjectType.sol";
import { registerObjectType } from "@tenet-registry/src/Utils.sol";
import { VoxelCoord, ObjectProperties, Action, ActionType, SimTable, BlockDirection } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, ConcentrativeSoilObjectID } from "@tenet-farming/src/Constants.sol";
import { Soil, SoilData } from "@tenet-farming/src/codegen/tables/Soil.sol";
import { SoilType } from "@tenet-farming/src/codegen/Types.sol";
import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { entityIsSoil, entityIsPlant } from "@tenet-farming/src/Utils.sol";
import { absoluteDifference } from "@tenet-utils/src/MathUtils.sol";
import { calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { NUTRIENT_TRANSFER_MAX_DELTA } from "@tenet-simulator/src/Constants.sol";

contract ConcentrativeSoilObjectSystem is ObjectType {
  function registerObject() public {
    address world = _world();
    registerObjectType(
      REGISTRY_ADDRESS,
      ConcentrativeSoilObjectID,
      world,
      IWorld(world).farming_ConcentrativeSoi_enterWorld.selector,
      IWorld(world).farming_ConcentrativeSoi_exitWorld.selector,
      IWorld(world).farming_ConcentrativeSoi_eventHandler.selector,
      IWorld(world).farming_ConcentrativeSoi_neighbourEventHandler.selector,
      "Concentrative Soil",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    address worldAddress = _msgSender();
    ObjectProperties memory objectProperties;
    objectProperties.mass = 5;

    // Init NPK values
    objectProperties.nitrogen = 30;
    objectProperties.phosphorus = 30;
    objectProperties.potassium = 30;

    Soil.set(
      worldAddress,
      objectEntityId,
      SoilData({ lastInteractionBlock: 0, soilType: SoilType.Concentrative, hasValue: true })
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
      return getNutrientConversionActions(worldAddress, centerObjectEntityId, coord, entityProperties);
    }

    Action[] memory actions = new Action[](neighbourObjectEntityIds.length * 2);
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
        if (
          entityProperties.nutrients < neighbourEntityProperties.nutrients &&
          absoluteDifference(entityProperties.nutrients, neighbourEntityProperties.nutrients) <=
          NUTRIENT_TRANSFER_MAX_DELTA
        ) {
          uint256 nutrientsTransferAmount = entityProperties.nutrients / 10; // 10%
          if (nutrientsTransferAmount > 0) {
            actions[i * 2] = Action({
              actionType: ActionType.Transfer,
              senderTable: SimTable.Nutrients,
              senderValue: abi.encode(uint256ToNegativeInt256(nutrientsTransferAmount)),
              targetObjectEntityId: neighbourObjectEntityIds[i],
              targetCoord: neighbourCoord,
              targetTable: SimTable.Nutrients,
              targetValue: abi.encode(uint256ToInt256(nutrientsTransferAmount))
            });
            entityProperties.nutrients -= nutrientsTransferAmount;
          }
        }
      } else if (isValidPlantNeighbour(worldAddress, coord, neighbourObjectEntityIds[i], neighbourCoord)) {
        if (entityProperties.nutrients / 2 > 0) {
          uint256 elixirTransferAmount = entityProperties.nutrients / 2;
          uint256 proteinTransferAmount = entityProperties.nutrients / 2;

          actions[i * 2] = Action({
            actionType: ActionType.Transfer,
            senderTable: SimTable.Nutrients,
            senderValue: abi.encode(uint256ToNegativeInt256(elixirTransferAmount)),
            targetObjectEntityId: neighbourObjectEntityIds[i],
            targetCoord: neighbourCoord,
            targetTable: SimTable.Elixir,
            targetValue: abi.encode(uint256ToInt256(elixirTransferAmount))
          });
          actions[i * 2 + 1] = Action({
            actionType: ActionType.Transfer,
            senderTable: SimTable.Nutrients,
            senderValue: abi.encode(uint256ToNegativeInt256(proteinTransferAmount)),
            targetObjectEntityId: neighbourObjectEntityIds[i],
            targetCoord: neighbourCoord,
            targetTable: SimTable.Protein,
            targetValue: abi.encode(uint256ToInt256(proteinTransferAmount))
          });

          entityProperties.nutrients -= elixirTransferAmount + proteinTransferAmount;
        }
      }
    }

    Soil.setLastInteractionBlock(worldAddress, centerObjectEntityId, block.number);

    return actions;
  }

  function isValidPlantNeighbour(
    address worldAddress,
    VoxelCoord memory coord,
    bytes32 neighbourObjectEntityId,
    VoxelCoord memory neighbourCoord
  ) internal returns (bool) {
    BlockDirection neighbourBlockDirection = calculateBlockDirection(coord, neighbourCoord);
    if (neighbourBlockDirection != BlockDirection.Up) {
      return false;
    }

    if (!entityIsPlant(worldAddress, neighbourObjectEntityId)) {
      return false;
    }

    return true;
  }

  function getNutrientConversionActions(
    address worldAddress,
    bytes32 centerObjectEntityId,
    VoxelCoord memory coord,
    ObjectProperties memory entityProperties
  ) internal returns (Action[] memory) {
    Action[] memory conversionActions = new Action[](1);
    conversionActions[0] = Action({
      actionType: ActionType.Transformation,
      senderTable: SimTable.Energy,
      senderValue: abi.encode(uint256ToNegativeInt256(entityProperties.energy)),
      targetObjectEntityId: centerObjectEntityId,
      targetCoord: coord,
      targetTable: SimTable.Nutrients,
      targetValue: abi.encode(uint256ToInt256(entityProperties.energy))
    });
    return conversionActions;
  }

  function neighbourEventHandler(
    bytes32 neighbourObjectEntityId,
    bytes32 centerObjectEntityId
  ) public override returns (bool, Action[] memory) {
    return (false, new Action[](0));
  }
}
