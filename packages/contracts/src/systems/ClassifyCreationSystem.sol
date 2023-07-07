// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../types.sol";
import { OwnedBy, Position, PositionTableId, VoxelType, Spawn, SpawnTableId, Classifier, ClassifierData, ClassifierTableId } from "../codegen/Tables.sol";
import { addressToEntityKey, getEntitiesAtCoord } from "../utils.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { Occurrence } from "../codegen/Tables.sol";
import { console } from "forge-std/console.sol";
import { CHUNK_MAX_Y, CHUNK_MIN_Y } from "../Constants.sol";

contract ClassifyCreationSystem is System {
  function classify(bytes32 classifierId, bytes32 spawnId, bytes memory input) public {
    // check if voxel type is already registered
    bytes32[] memory classifierKeyTuple = new bytes32[](1);
    classifierKeyTuple[0] = classifierId;
    require(hasKey(ClassifierTableId, classifierKeyTuple), "Classifier doesn't exist");

    bytes32[] memory spawnKeyTuple = new bytes32[](1);
    spawnKeyTuple[0] = spawnId;
    require(hasKey(SpawnTableId, spawnKeyTuple), "Spawn doesn't exist");

    ClassifierData memory classifier = Classifier.get(classifierId);

    // call classifySelector with input
    (bool success, bytes memory data) = _world().call(abi.encodeWithSelector(classifier.classifySelector, input));
    require(success, "Classifier test failed");
  }
}
