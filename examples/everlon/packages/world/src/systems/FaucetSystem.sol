// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { ObjectType, Faucet, FaucetData, FaucetTableId } from "@tenet-world/src/codegen/Tables.sol";

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityIdFromObjectEntityId, getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";

uint256 constant MAX_CLAIMS = 8;

contract FaucetSystem is System {
  // TODO: Could this just be in the faucet object type code?
  function claimAgentFromFaucet(
    bytes32 faucetObjectEntityId,
    bytes32 buildObjectTypeId,
    VoxelCoord memory buildCoord
  ) public returns (bytes32) {
    require(hasKey(FaucetTableId, Faucet.encodeKeyTuple(faucetObjectEntityId)), "Faucet entity not found");
    FaucetData memory facuetData = Faucet.get(faucetObjectEntityId);
    address claimer = _msgSender();
    uint256 numClaims = 0;
    uint256 claimIdx = 0;
    for (uint256 i = 0; i < facuetData.claimers.length; i++) {
      if (facuetData.claimers[i] == claimer) {
        numClaims = facuetData.claimerAmounts[i];
        claimIdx = i;
        break;
      }
    }
    require(numClaims < MAX_CLAIMS, "FaucetSystem: Max claims reached");
    if (numClaims == 0) {
      // Create new array
      address[] memory newClaimers = new address[](facuetData.claimers.length + 1);
      uint256[] memory newClaimerAmounts = new uint256[](facuetData.claimerAmounts.length + 1);
      for (uint256 i = 0; i < facuetData.claimers.length; i++) {
        newClaimers[i] = facuetData.claimers[i];
        newClaimerAmounts[i] = facuetData.claimerAmounts[i];
      }
      newClaimers[facuetData.claimers.length] = claimer;
      newClaimerAmounts[facuetData.claimerAmounts.length] = 1;
      facuetData.claimers = newClaimers;
      facuetData.claimerAmounts = newClaimerAmounts;
    } else {
      // Update existing array
      facuetData.claimerAmounts[claimIdx] = numClaims + 1;
    }

    // Note: calling build every time will cause the area around the agent to lose energy
    // TODO: Fix this if it becomes a problem. One idea is the faucet entity could flux energy back to the surrounding
    bytes32 newEntityId = IWorld(_world()).build(faucetObjectEntityId, buildObjectTypeId, buildCoord);
    IWorld(_world()).claimAgent(newEntityId);
    Faucet.set(faucetObjectEntityId, facuetData);

    bytes32 faucetEntityId = getEntityIdFromObjectEntityId(IStore(_world()), faucetObjectEntityId);

    IWorld(_world()).activate(
      faucetObjectEntityId,
      ObjectType.get(faucetEntityId),
      getVoxelCoordStrict(IStore(_world()), faucetEntityId)
    );

    return newEntityId;
  }
}
