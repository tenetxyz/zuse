// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EntityActionData, SimTable, Action } from "@tenet-utils/src/Types.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { Faucet, FaucetData, AgentFaucet, FaucetTableId } from "@tenet-world/src/codegen/Tables.sol";

import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { ActionSystem as ActionProtoSystem } from "@tenet-base-world/src/systems/ActionSystem.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";

import { SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { getEntityIdFromObjectEntityId } from "@tenet-base-world/src/Utils.sol";
import { removeEntityFromAddressArray, removeIdxFromUint256Array, removeIdxFromBytes32DoubleArray, removeEntityFromBytes32Array } from "@tenet-utils/src/ArrayUtils.sol";

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

        // mine the object
        bytes32 targetObjectTypeId = ObjectType.get(
          getEntityIdFromObjectEntityId(IStore(_world()), action.targetObjectEntityId)
        );
        IWorld(_world()).mine(bytes32(0), targetObjectTypeId, action.targetCoord);

        // remove owner
        OwnedBy.deleteRecord(action.targetObjectEntityId);

        // Remove from faucet
        bytes32 faucetObjectEntityId = AgentFaucet.get(action.targetObjectEntityId);
        FaucetData memory faucetData = Faucet.get(faucetObjectEntityId);
        bytes32[][] memory faucetClaimers = abi.decode(faucetData.claimerObjectEntityIds, (bytes32[][]));
        for (uint256 i = 0; i < faucetClaimers.length; i++) {
          bool found = false;
          for (uint256 j = 0; j < faucetClaimers[i].length; j++) {
            if (faucetClaimers[i][j] == action.targetObjectEntityId) {
              if (faucetData.claimerAmounts[i] == 1) {
                // remove from array
                address[] memory newClaimers = removeEntityFromAddressArray(
                  faucetData.claimers,
                  faucetData.claimers[i]
                );
                uint256[] memory newClaimerAmounts = removeIdxFromUint256Array(faucetData.claimerAmounts, i);
                bytes32[][] memory newClaimerObjectEntityIds = removeIdxFromBytes32DoubleArray(faucetClaimers, i);
                faucetData.claimers = newClaimers;
                faucetData.claimerAmounts = newClaimerAmounts;
                faucetData.claimerObjectEntityIds = abi.encode(newClaimerObjectEntityIds);
              } else {
                // remove from array
                bytes32[] memory newClaimerObjectEntityIds = removeEntityFromBytes32Array(
                  faucetClaimers[i],
                  faucetClaimers[i][j]
                );
                faucetClaimers[i] = newClaimerObjectEntityIds;
                faucetData.claimerObjectEntityIds = abi.encode(faucetClaimers);
                faucetData.claimerAmounts[i] = faucetData.claimerAmounts[i] - 1;
              }

              found = true;
              break;
            }
          }

          if (found) {
            Faucet.set(faucetObjectEntityId, faucetData);
            break;
          }
        }
        AgentFaucet.deleteRecord(action.targetObjectEntityId);
      }
    }
  }
}
