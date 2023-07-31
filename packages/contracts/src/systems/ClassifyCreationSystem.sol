// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, Spawn, SpawnTableId, Classifier, ClassifierData, ClassifierTableId } from "@tenet-contracts/src/codegen/Tables.sol";
import { getEntitiesAtCoord } from "../utils.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { InterfaceVoxel } from "@tenet-contracts/src/Types.sol";
import { SpawnData, OfSpawn } from "@tenet-contracts/src/codegen/Tables.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract ClassifyCreationSystem is System {
  function classify(bytes32 classifierId, bytes32 spawnId, InterfaceVoxel[] memory input) public {
    // check if classifier is already registered
    bytes32[] memory classifierKeyTuple = new bytes32[](1);
    classifierKeyTuple[0] = classifierId;
    require(hasKey(ClassifierTableId, classifierKeyTuple), "Classifier doesn't exist");

    // check if spawn exists
    bytes32[] memory spawnKeyTuple = new bytes32[](1);
    spawnKeyTuple[0] = spawnId;
    require(hasKey(SpawnTableId, spawnKeyTuple), "Spawn doesn't exist");

    // check that the spawn hasn't been modified
    require(!Spawn.get(spawnId).isModified, "You can only submit Spawns that haven't been modified");

    verifyThatAllInterfaceVoxelsExistInSpawn(spawnId, input);

    ClassifierData memory classifier = Classifier.get(classifierId);

    // verifyCreationHasntBeenSubmittedBefore(classifier, spawnId); // commented for now since it's unused

    SpawnData memory spawn = Spawn.get(spawnId);

    // call classifySelector with input
    safeCall(_world(), abi.encodeWithSelector(classifier.classifySelector, spawn, spawnId, input), "classify");
  }

  function verifyThatAllInterfaceVoxelsExistInSpawn(bytes32 spawnId, InterfaceVoxel[] memory input) private view {
    for (uint32 i = 0; i < input.length; i++) {
      bytes32 voxel = input[i].entity;
      require(uint256(voxel) != 0, "Interface voxel cannot be 0");
      // TODO: Fix by adding scale
      // require(OfSpawn.get(voxel) == spawnId, "All voxels in the interface must be in the spawn");
    }
  }

  function verifyCreationHasntBeenSubmittedBefore(ClassifierData memory classifier, bytes32 spawnId) private {
    // TODO: implement
  }
}
