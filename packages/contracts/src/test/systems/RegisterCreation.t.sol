// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { addressToEntityKey } from "../../utils.sol";
import { VoxelCoord } from "../../types.sol";
import { OwnedBy, VoxelType } from "../../codegen/Tables.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { CyanWoolID } from "../../prototypes/Voxels.sol";
import { Utilities } from "@latticexyz/std-contracts/src/test/Utilities.sol";

contract RegisterCreationTest is MudV2Test {
  IWorld private world;
  IStore private store;
  Utilities internal immutable utils = new Utilities();

  address payable internal alice;
  bytes32 voxel1;
  bytes32 voxel2;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);

    alice = utils.getNextUserAddress();
  }

  function testRegisterCreation() public {
    vm.startPrank(alice);


    // Give two voxels to alice
    voxel1 = bytes32(uint256(1)); // For some reason, I can't use: voxel1 = getUniqueEntity();
//    voxel1 = getUniqueEntity();
//    require(false, "failed here2");
    VoxelType.set(voxel1, CyanWoolID);
    OwnedBy.set(voxel1, addressToEntityKey(alice));

//    voxel2 = getUniqueEntity();
    voxel2 = bytes32(uint256(2));
    VoxelType.set(voxel2, CyanWoolID);
    OwnedBy.set(voxel2, addressToEntityKey(alice));

    VoxelCoord memory coord1 = VoxelCoord(1, 2, 1);
    VoxelCoord memory coord2 = VoxelCoord(2, 1, 2);
    world.build(voxel1, coord1);
    world.build(voxel2, coord2);
//    require(false, "failed here");

    world.registerCreation("test creation name", coord1, coord2);
    vm.stopPrank();
  }
}
