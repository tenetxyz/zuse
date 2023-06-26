// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { Spawn, SpawnData } from "../codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";

contract SetInterfaceVoxelsSystem is System {
  // declares which voxels are used for i/o interfaces (e.g. for an AND gate test)
  function declareVoxelsForInterface(bytes32 spawnId, bytes32[] memory voxels) public {
    // TODO: error if this spawnId doesn't exist
    SpawnData memory spawn = Spawn.get(spawnId);
    spawn.interfaceVoxels = voxels;
    Spawn.set(spawnId, spawn);
  }
}
