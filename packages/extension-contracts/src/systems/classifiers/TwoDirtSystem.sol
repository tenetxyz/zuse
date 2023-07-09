// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { TwoDirtCR } from "@tenet-extension-contracts/src/codegen/tables.sol";
import { Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelType } from "@tenet-contracts/src/codegen/tables/voxelType.sol";
import { Classifier } from "@tenet-contracts/src/prototypes/Classifier.sol";

// This doesn't work since we can't import the dependencies (cause it uses relative paths)
// import { DirtID } from "@tenet-contracts/src/systems/voxels/DirtVoxelSystem.sol";
bytes32 constant DirtID = keccak256("dirt");

contract TwoDirtSystem is Classifier {
  function classify(
    address worldAddress,
    SpawnData memory spawn,
    bytes32 spawnId,
    bytes32[] memory input
  ) public override {
    require(!TwoDirtCR.get(spawn.creationId).hasValue, "this creation has already been classified"); // TODO: put this into classify creation system
    require(spawn.voxels.length == 2, "the spawn must have exactly 2 voxels");
    for (uint8 i = 0; i < spawn.voxels.length; i++) {
      bytes32 voxel = spawn.voxels[i];
      bytes32 voxelTypeId = VoxelType.getVoxelTypeId(voxel);
      require(voxelTypeId == DirtID, "voxels must be dirt");
    }
    TwoDirtCR.set(spawn.creationId, true, block.number);
  }
}
