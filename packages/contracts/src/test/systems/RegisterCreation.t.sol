// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { VoxelCoord, BaseCreationInWorld, VoxelEntity } from "@tenet-contracts/src/Types.sol";
import { OwnedBy, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { GrassVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { Utilities } from "@latticexyz/std-contracts/src/test/Utilities.sol";
import { console } from "forge-std/console.sol";

contract RegisterCreationTest is MudTest {
  IWorld private world;
  IStore private store;
  Utilities internal immutable utils = new Utilities();

  address payable internal alice;
  bytes16 namespace;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);

    alice = utils.getNextUserAddress();
  }

  function testGetVoxelTypes() public {
    vm.startPrank(alice);

    bytes32 voxel1 = world.giftVoxel(GrassVoxelID);
    VoxelEntity[] memory voxels = new VoxelEntity[](1);
    voxels[0] = VoxelEntity({ scale: 1, entityId: voxel1 });
    VoxelTypeData[] memory voxelTypes = world.getVoxelTypes(voxels);
    assertEq(voxelTypes[0].voxelTypeId, GrassVoxelID);

    vm.stopPrank();
  }

  function testRegisterCreation() public {
    vm.startPrank(alice);

    // Give two voxels to alice

    // NOTE: I don't think you can call Component.set(store, value);, you can only call Component.get(store, key);
    // This is why I am gifting the voxels to Alice.
    // For some reason, you also can't use: voxel1 = getUniqueEntity();
    bytes32 giftedVoxel = world.giftVoxel(GrassVoxelID);

    VoxelCoord memory coord1 = VoxelCoord(1, 2, 1);
    VoxelCoord memory coord2 = VoxelCoord(2, 1, 2);

    // the build system spawns a new voxel before placing the newly spawned voxel in the world
    bytes32 voxel1 = world.build(1, giftedVoxel, coord1);
    bytes32 voxel2 = world.build(1, giftedVoxel, coord2);

    VoxelEntity[] memory voxels = new VoxelEntity[](2);
    voxels[0] = VoxelEntity({ scale: 1, entityId: voxel1 });
    voxels[1] = VoxelEntity({ scale: 1, entityId: voxel2 });

    BaseCreationInWorld[] memory baseCreationsInWorld = new BaseCreationInWorld[](0);
    world.registerCreation("test creation name", "test creation desc", voxels, baseCreationsInWorld);
    vm.stopPrank();
  }
}
