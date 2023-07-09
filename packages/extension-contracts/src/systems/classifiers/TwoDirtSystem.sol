// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { query, QueryFragment, QueryType } from "@latticexyz/world/src/modules/keysintable/query.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { getVoxelCoordStrict } from "../../Utils.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { VoxelCoord } from "@tenetxyz/contracts/src/Types.sol";
import { entityIsPowered, clearCoord, build } from "../../Utils.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { TwoDirtCR } from "../../codegen/tables.sol";
import { Spawn, SpawnData } from "@tenetxyz/contracts/src/codegen/tables/spawn.sol";
import { VoxelType } from "@tenetxyz/contracts/src/codegen/tables/voxelType.sol";

// This doesnt' work since we can't import the dependencies (cause it uses relative paths)
// import { DirtID } from "@tenetxyz/contracts/src/systems/voxels/DirtVoxelSystem.sol";

contract TwoDirtSystem is System {
  function classify(
    bytes32[] memory input,
    address worldAddress,
    bytes32[] memory voxelInterfaces,
    bytes32 spawnId
  ) public {
    SpawnData memory spawn = Spawn.get(spawnId);
    require(spawn.voxels.length == 2, "the spawn must have exactly 2 voxels");
    for (uint8 i = 0; i < spawn.voxels.length; i++) {
      bytes32 voxel = spawn.voxels[i];
      bytes32 voxelTypeId = VoxelType.getVoxelTypeId(voxel);
      require(voxelTypeId == bytes32(keccak256("dirt")), "voxels must be dirt");
    }
    TwoDirtCR.set(spawn.creationId, block.number); // just pass anything that is submitted
  }
}
