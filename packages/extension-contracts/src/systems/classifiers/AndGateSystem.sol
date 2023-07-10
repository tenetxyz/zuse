// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { query, QueryFragment, QueryType } from "@latticexyz/world/src/modules/keysintable/query.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { getVoxelCoordStrict, entitiesToRelativeVoxelCoords, getCallerNamespace } from "@tenet-contracts/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "@tenet-extension-contracts/src/codegen/world/IWorld.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { removeAllOwnedVoxels, entityIsActiveSignal, entityIsInactiveSignal, clearCoord, build, giftVoxel } from "../../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { AndGateCR } from "@tenet-extension-contracts/src/codegen/tables.sol";
import { Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { Classifier } from "@tenet-contracts/src/prototypes/Classifier.sol";
import { EXTENSION_NAMESPACE } from "@tenet-extension-contracts/src/constants.sol";
import { SignalSourceID } from "../voxels/SignalSourceVoxelSystem.sol";

contract AndGateSystem is Classifier {
  function classify(SpawnData memory spawn, bytes32 spawnId, bytes32[] memory input) public override {
    require(!AndGateCR.get(spawn.creationId).hasValue, "this creation has already been classified"); // TODO: put this into classify creation system
    // TODO: This can be moved to the abstract contract
    // require(input.length == 3, "AndGateSystem: input length must be 3");
    bytes32 in1 = input[0];
    bytes32 in2 = input[1];
    bytes32 out = input[2];

    VoxelCoord memory in1Coord = getVoxelCoordStrict(in1);
    VoxelCoord memory in2Coord = getVoxelCoordStrict(in2);

    // Setup
    bytes32 inEntity1 = giftVoxel(_world(), EXTENSION_NAMESPACE, SignalSourceID);
    bytes32 inEntity2 = giftVoxel(_world(), EXTENSION_NAMESPACE, SignalSourceID);

    // TODO: This can be moved to the abstract contract
    bytes32 originalEntity1 = clearCoord(_world(), in1Coord);
    bytes32 originalEntity2 = clearCoord(_world(), in2Coord);

    // Run tests
    simulateLogic(inEntity1, inEntity2, in1Coord, in2Coord, out, 0, 0, 0);
    simulateLogic(inEntity1, inEntity2, in1Coord, in2Coord, out, 1, 0, 0);
    simulateLogic(inEntity1, inEntity2, in1Coord, in2Coord, out, 0, 1, 0);
    simulateLogic(inEntity1, inEntity2, in1Coord, in2Coord, out, 1, 1, 1); // this is the only case where the output is on since both inputs are on

    VoxelCoord memory lowerSouthWestCorner = abi.decode(Spawn.getLowerSouthWestCorner(spawnId), (VoxelCoord));
    VoxelCoord[] memory interfaceCoords = entitiesToRelativeVoxelCoords(input, lowerSouthWestCorner);
    string memory resultStr = string(abi.encodePacked(Strings.toString(spawn.voxels.length), " blocks"));
    AndGateCR.set(spawn.creationId, true, block.number, resultStr, abi.encode(interfaceCoords));

    // Reset the world
    // TODO: This can be moved to the abstract contract
    clearCoord(_world(), in1Coord);
    clearCoord(_world(), in2Coord);
    if (uint256(originalEntity1) != 0) {
      build(_world(), in1Coord, originalEntity1);
    }
    if (uint256(originalEntity2) != 0) {
      build(_world(), in2Coord, originalEntity2);
    }
    removeAllOwnedVoxels(_world());
  }

  // the reason why the in/out states are uints is cause 1s and 0s are more readable than true/false
  function simulateLogic(
    bytes32 inEntity1,
    bytes32 inEntity2,
    VoxelCoord memory in1Coord,
    VoxelCoord memory in2Coord,
    bytes32 out,
    uint8 in1State,
    uint8 in2State,
    uint8 outState
  ) private {
    // mine the coord so we can place power sources at it
    clearCoord(_world(), in1Coord);
    clearCoord(_world(), in2Coord);

    if (in1State == 1) {
      build(_world(), in1Coord, inEntity1);
    }
    if (in2State == 1) {
      build(_world(), in2Coord, inEntity2);
    }

    // No need to run the simulation logic since the build function automatically runs the simulation logic
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    if (outState == 1) {
      require(entityIsActiveSignal(out, callerNamespace), "out voxel must be on");
    } else {
      require(entityIsInactiveSignal(out, callerNamespace), "out voxel cannot be on");
    }
  }
}
