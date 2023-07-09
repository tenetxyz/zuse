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
  function classify(bytes32 classifierId, bytes32 spawnId, bytes32[] memory input) public {
    // check if classifier is already registered
    bytes32[] memory classifierKeyTuple = new bytes32[](1);
    classifierKeyTuple[0] = classifierId;
    require(hasKey(ClassifierTableId, classifierKeyTuple), "Classifier doesn't exist");

    // check if spawn is already registered
    bytes32[] memory spawnKeyTuple = new bytes32[](1);
    spawnKeyTuple[0] = spawnId;
    require(hasKey(SpawnTableId, spawnKeyTuple), "Spawn doesn't exist");

    // TODO: verify that all blocks in the voxelInterface exist in the spawn

    ClassifierData memory classifier = Classifier.get(classifierId);

    // call classifySelector with input
    (bool success, bytes memory returnData) = _world().call(
      abi.encodeWithSelector(classifier.classifySelector, _world(), spawnId, input)
    );

    if (!success) {
      // if there is a return reason string
      if (returnData.length > 0) {
        // bubble up any reason for revert
        assembly {
          let returnDataSize := mload(returnData)
          revert(add(32, returnData), returnDataSize)
        }
      } else {
        revert("Call reverted. Maybe the params to classify() aren't right?");
      }
    }
  }
}
