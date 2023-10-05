// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelEntity, VoxelCoord, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Faucet, FaucetData, FaucetTableId, TerrainProperties, TerrainPropertiesTableId, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { SHARD_DIM } from "@tenet-level1-ca/src/Constants.sol";
import { coordToShardCoord } from "@tenet-level1-ca/src/Utils.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { getInteractionSelectors } from "@tenet-registry/src/Utils.sol";
import { console } from "forge-std/console.sol";

uint256 constant MAX_CLAIMS = 2;

contract FaucetSystem is System {
  function claimAgentFromFaucet(
    VoxelEntity memory faucetEntity,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) public returns (VoxelEntity memory) {
    require(
      hasKey(FaucetTableId, Faucet.encodeKeyTuple(faucetEntity.scale, faucetEntity.entityId)),
      "Faucet entity not found"
    );
    FaucetData memory facuetData = Faucet.get(faucetEntity.scale, faucetEntity.entityId);
    address claimer = tx.origin;
    uint256 numClaims = 0;
    uint256 claimIdx = 0;
    for (uint256 i = 0; i < facuetData.claimers.length; i++) {
      if (facuetData.claimers[i] == claimer) {
        numClaims = facuetData.claimerAmounts[i];
        claimIdx = i;
      }
    }
    require(numClaims < MAX_CLAIMS, "Max claims reached");
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
    } else {
      // Update existing array
      facuetData.claimerAmounts[claimIdx] = numClaims + 1;
    }

    // Make sure entity is an agent
    InteractionSelector[] memory interactionSelectors = getInteractionSelectors(IStore(REGISTRY_ADDRESS), voxelTypeId);
    require(interactionSelectors.length > 1, "Not an agent");

    VoxelEntity memory newEntity = IWorld(_world()).buildWithAgent(voxelTypeId, coord, faucetEntity, bytes4(0));
    IWorld(_world()).claimAgent(newEntity);
    Faucet.set(faucetEntity.scale, faucetEntity.entityId, facuetData);

    return newEntity;
  }

  function setFaucetAgent(VoxelEntity memory faucetEntity) public {
    // TODO: should be set based on terrain gen
    require(
      _msgSender() == 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, // TODO: find a better way to figure out world deployer
      "Not approved to set faucet agent"
    );
    require(
      !hasKey(FaucetTableId, Faucet.encodeKeyTuple(faucetEntity.scale, faucetEntity.entityId)),
      "Faucet entity already exists"
    );
    Faucet.set(
      faucetEntity.scale,
      faucetEntity.entityId,
      FaucetData({ claimers: new address[](0), claimerAmounts: new uint256[](0) })
    );
  }
}