// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { ObjectMetadata, ObjectMetadataTableId } from "@tenet-world/src/codegen/tables/ObjectMetadata.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";
import { Faucet, FaucetData, AgentFaucet, FaucetTableId } from "@tenet-world/src/codegen/Tables.sol";

import { SIMULATOR_ADDRESS, AirObjectID } from "@tenet-world/src/Constants.sol";
import { MineSystem as MineProtoSystem } from "@tenet-base-world/src/systems/MineSystem.sol";
import { removeEntityFromAddressArray, removeIdxFromUint256Array, removeIdxFromBytes32DoubleArray, removeEntityFromBytes32Array } from "@tenet-utils/src/ArrayUtils.sol";

contract MineSystem is MineProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function postEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes memory eventData
  ) internal override {
    super.postEvent(actingObjectEntityId, objectTypeId, coord, eventEntityId, eventData);

    address callerAddress = _msgSender();
    // Clear all keys in Metadata if not called by World or Simulator
    // This would typically represent the end of a user call, vs the end of
    // an internal call
    if (callerAddress != _world() && callerAddress != getSimulatorAddress()) {
      bytes32[][] memory objectsRan = getKeysInTable(ObjectMetadataTableId);
      for (uint256 i = 0; i < objectsRan.length; i++) {
        ObjectMetadata.deleteRecord(objectsRan[i][0]);
      }
    }
  }

  function mine(
    bytes32 actingObjectEntityId,
    bytes32 mineObjectTypeId,
    VoxelCoord memory mineCoord
  ) public override returns (bytes32) {
    return super.mine(actingObjectEntityId, mineObjectTypeId, mineCoord, new bytes(0));
  }

  function postRunObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bytes memory eventData
  ) internal override {
    bool hasOwner = OwnedBy.get(objectEntityId) != address(0);
    if (hasOwner) {
      // Remove from faucet
      bytes32 faucetObjectEntityId = AgentFaucet.get(objectEntityId);
      FaucetData memory faucetData = Faucet.get(faucetObjectEntityId);
      bytes32[][] memory faucetClaimers = abi.decode(faucetData.claimerObjectEntityIds, (bytes32[][]));
      for (uint256 i = 0; i < faucetClaimers.length; i++) {
        bool found = false;
        for (uint256 j = 0; j < faucetClaimers[i].length; j++) {
          if (faucetClaimers[i][j] == objectEntityId) {
            if (faucetData.claimerAmounts[i] == 1) {
              // remove from array
              address[] memory newClaimers = removeEntityFromAddressArray(faucetData.claimers, faucetData.claimers[i]);
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
      AgentFaucet.deleteRecord(objectEntityId);
    }

    // Note: has to run after the above logic, as it removes the owner from the object
    super.postRunObject(actingObjectEntityId, objectTypeId, coord, eventEntityId, objectEntityId, eventData);
  }
}
