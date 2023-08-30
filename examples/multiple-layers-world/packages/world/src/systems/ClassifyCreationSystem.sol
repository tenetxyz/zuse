// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, Spawn, SpawnTableId } from "@tenet-world/src/codegen/Tables.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ClassifierRegistry, ClassifierRegistryTableId } from "@tenet-registry/src/codegen/tables/ClassifierRegistry.sol";
import { InterfaceVoxel, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { SpawnData, OfSpawn } from "@tenet-world/src/codegen/Tables.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract ClassifyCreationSystem is System {
  function classify(bytes32 classifierId, bytes32 spawnId, InterfaceVoxel[] memory input) public {
    require(
      hasKey(IStore(REGISTRY_ADDRESS), ClassifierRegistryTableId, ClassifierRegistry.encodeKeyTuple(classifierId)),
      "Classifier doesn't exist"
    );

    // check if spawn exists
    bytes32[] memory spawnKeyTuple = new bytes32[](1);
    spawnKeyTuple[0] = spawnId;
    require(hasKey(SpawnTableId, spawnKeyTuple), "Spawn doesn't exist");

    // check that the spawn hasn't been modified
    require(!Spawn.get(spawnId).isModified, "You can only submit Spawns that haven't been modified");

    verifyThatAllInterfaceVoxelsExistInSpawn(spawnId, input);

    bytes4 classifySelector = ClassifierRegistry.getClassifySelector(classifierId);

    SpawnData memory spawn = Spawn.get(spawnId);

    // call classifySelector with input
    safeCall(_world(), abi.encodeWithSelector(classifySelector, spawn, spawnId, input), "classify");
  }

  function verifyThatAllInterfaceVoxelsExistInSpawn(bytes32 spawnId, InterfaceVoxel[] memory input) internal view {
    for (uint32 i = 0; i < input.length; i++) {
      VoxelEntity memory voxel = input[i].entity;
      require(OfSpawn.get(voxel.scale, voxel.entityId) == spawnId, "All voxels in the interface must be in the spawn");
    }
  }
}
