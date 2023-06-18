// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../codegen/world/IWorld.sol";

contract InitSystem is System {
    function init() public {
        IWorld world = IWorld(_world());
        world.tenet_VoxelSystem_defineVoxels();
    }
}
