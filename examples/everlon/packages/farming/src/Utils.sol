// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord, ObjectProperties, Action, ActionType, SimTable, BlockDirection } from "@tenet-utils/src/Types.sol";

import { calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";

import { Soil } from "@tenet-farming/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-farming/src/codegen/tables/Plant.sol";
import { Farmer } from "@tenet-farming/src/codegen/tables/Farmer.sol";

function entityIsSoil(address worldAddress, bytes32 objectEntityId) view returns (bool) {
  return Soil.getHasValue(worldAddress, objectEntityId);
}

function entityIsPlant(address worldAddress, bytes32 objectEntityId) view returns (bool) {
  return Plant.getHasValue(worldAddress, objectEntityId);
}

function entityIsFarmer(address worldAddress, bytes32 objectEntityId) view returns (bool) {
  return Farmer.getHasValue(worldAddress, objectEntityId);
}

function isValidPlantNeighbour(
  address worldAddress,
  VoxelCoord memory coord,
  bytes32 neighbourObjectEntityId,
  VoxelCoord memory neighbourCoord
) view returns (bool) {
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
  bytes32 centerObjectEntityId,
  VoxelCoord memory coord,
  ObjectProperties memory entityProperties
) pure returns (Action[] memory) {
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
