// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { TwoDirtCR } from "@tenetxyz/contracts/src/codegen/tables.sol";
import { Spawn, SpawnData } from "@tenetxyz/contracts/src/codegen/tables/spawn.sol";
import { VoxelType } from "@tenetxyz/contracts/src/codegen/tables/voxelType.sol";

// This doesn't work since we can't import the dependencies (cause it uses relative paths)
// import { DirtID } from "@tenetxyz/contracts/src/systems/voxels/DirtVoxelSystem.sol";
bytes32 constant DirtID = keccak256("dirt");

contract TwoDirtSystem is System {
  function classify(address worldAddress, bytes32 spawnId, bytes32[] memory input) public {
    SpawnData memory spawn = Spawn.get(spawnId);
    require(spawn.voxels.length == 2, "the spawn must have exactly 2 voxels");
    for (uint8 i = 0; i < spawn.voxels.length; i++) {
      bytes32 voxel = spawn.voxels[i];
      bytes32 voxelTypeId = VoxelType.getVoxelTypeId(voxel);
      require(voxelTypeId == DirtID, "voxels must be dirt");
    }
    TwoDirtCR.set(spawn.creationId, block.number);
  }
}
