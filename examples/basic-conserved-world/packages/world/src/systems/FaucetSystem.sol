// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelEntity, VoxelCoord, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Faucet, FaucetTableId, TerrainProperties, TerrainPropertiesTableId, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { SHARD_DIM } from "@tenet-level1-ca/src/Constants.sol";
import { coordToShardCoord } from "@tenet-level1-ca/src/Utils.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { getInteractionSelectors } from "@tenet-registry/src/Utils.sol";
import { console } from "forge-std/console.sol";

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
    // Make sure entity is an agent
    InteractionSelector[] memory interactionSelectors = getInteractionSelectors(IStore(REGISTRY_ADDRESS), voxelTypeId);
    require(interactionSelectors.length > 1, "Not an agent");

    VoxelEntity memory newEntity = IWorld(_world()).buildWithAgent(voxelTypeId, coord, faucetEntity, bytes4(0));
    IWorld(_world()).claimAgent(newEntity);

    Faucet.set(faucetEntity.scale, faucetEntity.entityId, Faucet.get(faucetEntity.scale, faucetEntity.entityId) + 1);
    return newEntity;
  }

  function setFaucetAgent(VoxelEntity memory faucetEntity) public {
    require(
      _msgSender() == 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, // TODO: find a better way to figure out world deployer
      "Not approved to set faucet agent"
    );
    require(
      !hasKey(FaucetTableId, Faucet.encodeKeyTuple(faucetEntity.scale, faucetEntity.entityId)),
      "Faucet entity already exists"
    );
    Faucet.set(faucetEntity.scale, faucetEntity.entityId, 0);
  }
}
