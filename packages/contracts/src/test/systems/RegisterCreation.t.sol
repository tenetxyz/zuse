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
import { console } from "forge-std/console.sol";

contract RegisterCreationTest is MudV2Test {
  IWorld private world;
  IStore private store;
  Utilities internal immutable utils = new Utilities();

  address payable internal alice;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);

    alice = utils.getNextUserAddress();

  }

  function testRegisterCreation() public {
    vm.startPrank(alice);

    // Give two voxels to alice

    // NOTE: I don't think you can call Component.set(store, value);, you can only call Component.get(store, key);
    // This is why I am gifting the voxels to Alice.
    // For some reason, you also can't use: voxel1 = getUniqueEntity();
    bytes32 voxel1 = world.tenet_GiftVoxelSystem_giftVoxel(CyanWoolID);
    bytes32 voxel2 = world.tenet_GiftVoxelSystem_giftVoxel(CyanWoolID);

    VoxelCoord memory coord1 = VoxelCoord(1, 2, 1);
    VoxelCoord memory coord2 = VoxelCoord(2, 1, 2);
    world.tenet_BuildSystem_build(voxel1, coord1);
    world.tenet_BuildSystem_build(voxel2, coord2);

    world.tenet_RegisterCreation_registerCreation("test creation name", coord1, coord2);
    vm.stopPrank();
  }
}
