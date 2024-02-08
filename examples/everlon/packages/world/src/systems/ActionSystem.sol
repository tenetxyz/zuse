// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EntityActionData, SimTable, Action } from "@tenet-utils/src/Types.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { ActionSystem as ActionProtoSystem } from "@tenet-base-world/src/systems/ActionSystem.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";

import { SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { getEntityIdFromObjectEntityId } from "@tenet-base-world/src/Utils.sol";

contract ActionSystem is ActionProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function actionHandler(EntityActionData memory entityActionData) public override returns (bool ranAction) {
    return super.actionHandler(entityActionData);
  }

  function postRunAction(
    bytes32 objectEntityId,
    VoxelCoord memory entityCoord,
    Action memory action
  ) internal override {
    if (action.targetTable == SimTable.Mass) {
      uint256 newMass = Mass.get(IStore(getSimulatorAddress()), _world(), action.targetObjectEntityId);
      if (newMass == 0) {
        bytes32 targetObjectTypeId = ObjectType.get(
          getEntityIdFromObjectEntityId(IStore(_world()), action.targetObjectEntityId)
        );
        IWorld(_world()).mine(objectEntityId, targetObjectTypeId, action.targetCoord);
      }
    } else if (action.targetTable == SimTable.Health) {
      uint256 newHealth = Health.getHealth(IStore(getSimulatorAddress()), _world(), action.targetObjectEntityId);
      if (newHealth == 0) {
        // transfer inventory to sender
        bytes32[][] memory inventoryIds = getKeysWithValue(
          InventoryTableId,
          Inventory.encode(action.targetObjectEntityId)
        );
        for (uint256 i = 0; i < inventoryIds.length; i++) {
          bytes32 inventoryId = inventoryIds[i][0];
          Inventory.set(inventoryId, objectEntityId);
        }
      }
    }
  }
}
