// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { ObjectType, ObjectEntity, Faucet, FaucetData, AgentFaucet, FaucetTableId, ObjectMetadata, ObjectMetadataTableId } from "@tenet-world/src/codegen/Tables.sol";

import { inSurroundingCube } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityIdFromObjectEntityId, getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";

uint256 constant MAX_CLAIMS_PER_FAUCET = 1;
uint256 constant MAX_TOTAL_CLAIMS = 1;

contract FaucetSystem is System {
  // TODO: Could this just be in the faucet object type code?
  function claimAgentFromFaucet(
    bytes32 faucetObjectEntityId,
    bytes32 buildObjectTypeId,
    VoxelCoord memory buildCoord
  ) public returns (bytes32) {
    require(hasKey(FaucetTableId, Faucet.encodeKeyTuple(faucetObjectEntityId)), "Faucet entity not found");
    address claimer = _msgSender();
    (FaucetData memory faucetData, uint256 numClaims, uint256 claimIdx) = requireNotClaimed(
      faucetObjectEntityId,
      claimer
    );
    bytes32[][] memory claimerObjectEntityIds = abi.decode(faucetData.claimerObjectEntityIds, (bytes32[][]));
    bytes32[][] memory newClaimerObjectEntityIds;
    if (numClaims == 0) {
      // Create new array
      address[] memory newClaimers = new address[](faucetData.claimers.length + 1);
      uint256[] memory newClaimerAmounts = new uint256[](faucetData.claimerAmounts.length + 1);
      newClaimerObjectEntityIds = new bytes32[][](claimerObjectEntityIds.length + 1);
      for (uint256 i = 0; i < faucetData.claimers.length; i++) {
        newClaimers[i] = faucetData.claimers[i];
        newClaimerAmounts[i] = faucetData.claimerAmounts[i];
        newClaimerObjectEntityIds[i] = claimerObjectEntityIds[i];
      }
      newClaimers[faucetData.claimers.length] = claimer;
      newClaimerAmounts[faucetData.claimerAmounts.length] = 1;
      newClaimerObjectEntityIds[claimerObjectEntityIds.length] = new bytes32[](1);

      faucetData.claimers = newClaimers;
      faucetData.claimerAmounts = newClaimerAmounts;
    } else {
      newClaimerObjectEntityIds = new bytes32[][](claimerObjectEntityIds.length);
      for (uint256 i = 0; i < claimerObjectEntityIds.length; i++) {
        newClaimerObjectEntityIds[i] = claimerObjectEntityIds[i];
      }
      newClaimerObjectEntityIds[claimIdx] = new bytes32[](claimerObjectEntityIds[claimIdx].length + 1);
      for (uint256 i = 0; i < claimerObjectEntityIds[claimIdx].length; i++) {
        newClaimerObjectEntityIds[claimIdx][i] = claimerObjectEntityIds[claimIdx][i];
      }
      // Update existing array
      faucetData.claimerAmounts[claimIdx] = numClaims + 1;
    }

    bytes32 faucetEntityId = getEntityIdFromObjectEntityId(IStore(_world()), faucetObjectEntityId);
    VoxelCoord memory faucetPosition = getVoxelCoordStrict(IStore(_world()), faucetEntityId);
    require(
      inSurroundingCube(faucetPosition, 1, buildCoord),
      "FaucetSystem: Cannot claim agent from faucet that is not adjacent to faucet"
    );

    // Note: calling build every time will cause the area around the agent to lose energy
    // TODO: Fix this if it becomes a problem. One idea is the faucet entity could flux energy back to the surrounding
    bytes32 newEntityId = IWorld(_world()).build(faucetObjectEntityId, buildObjectTypeId, buildCoord);
    bytes32 newObjectEntityId = ObjectEntity.get(newEntityId);
    IWorld(_world()).claimAgent(newEntityId);

    newClaimerObjectEntityIds[numClaims == 0 ? claimerObjectEntityIds.length : claimIdx][
      numClaims == 0 ? 0 : claimerObjectEntityIds[claimIdx].length
    ] = newObjectEntityId;
    faucetData.claimerObjectEntityIds = abi.encode(newClaimerObjectEntityIds);

    Faucet.set(faucetObjectEntityId, faucetData);
    AgentFaucet.set(newObjectEntityId, faucetObjectEntityId);

    IWorld(_world()).activate(faucetObjectEntityId, ObjectType.get(faucetEntityId), faucetPosition);

    // We need to clear the metadata table here because the
    // build and activate event will not clear them since it's an internal call
    bytes32[][] memory objectsRan = getKeysInTable(ObjectMetadataTableId);
    for (uint256 i = 0; i < objectsRan.length; i++) {
      ObjectMetadata.deleteRecord(objectsRan[i][0]);
    }

    return newEntityId;
  }

  function requireNotClaimed(
    bytes32 selectedFaucetObjectEntityId,
    address claimer
  ) internal view returns (FaucetData memory selectedfaucetData, uint256 numClaims, uint256 claimIdx) {
    bytes32[][] memory allFaucets = getKeysInTable(FaucetTableId);
    uint256 totalClaims = 0;
    for (uint256 i = 0; i < allFaucets.length; i++) {
      bytes32 faucetObjectEntityId = allFaucets[i][0];
      FaucetData memory faucetData = Faucet.get(faucetObjectEntityId);
      if (faucetObjectEntityId == selectedFaucetObjectEntityId) {
        selectedfaucetData = faucetData;
      }
      for (uint256 j = 0; j < faucetData.claimers.length; j++) {
        if (faucetData.claimers[j] == claimer) {
          if (faucetObjectEntityId == selectedFaucetObjectEntityId) {
            numClaims = faucetData.claimerAmounts[j];
            claimIdx = j;
            require(numClaims < MAX_CLAIMS_PER_FAUCET, "FaucetSystem: Max claims reached");
          }
          totalClaims += faucetData.claimerAmounts[j];
          break;
        }
      }
    }
    require(totalClaims < MAX_TOTAL_CLAIMS, "FaucetSystem: Max claims reached");
    return (selectedfaucetData, numClaims, claimIdx);
  }
}
