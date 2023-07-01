// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { addressToEntityKey } from "../../Utils.sol";
import { VoxelCoord } from "../../types.sol";
import { OwnedBy, VoxelType, VoxelTypeData } from "../../codegen/Tables.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { GrassID } from "../../prototypes/Voxels.sol";
import { Utilities } from "@latticexyz/std-contracts/src/test/Utilities.sol";
import { console } from "forge-std/console.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";

contract RegisterCreationTest is MudV2Test {
  IWorld private world;
  IStore private store;
  Utilities internal immutable utils = new Utilities();

  address payable internal alice;
  bytes16 namespace;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    namespace = TENET_NAMESPACE;

    alice = utils.getNextUserAddress();
  }

  function testGetVoxelTypes() public {
    vm.startPrank(alice);

    bytes32 voxel1 = world.tenet_GiftVoxelSystem_giftVoxel(namespace, GrassID);
    bytes32[] memory voxels = new bytes32[](1);
    voxels[0] = voxel1;
    VoxelTypeData[] memory voxelTypes = world.tenet_RegisterCreation_getVoxelTypes(voxels);
    assertEq(voxelTypes[0].voxelTypeId, GrassID);

    vm.stopPrank();
  }

  function testRegisterCreation() public {
    vm.startPrank(alice);

    // Give two voxels to alice

    // NOTE: I don't think you can call Component.set(store, value);, you can only call Component.get(store, key);
    // This is why I am gifting the voxels to Alice.
    // For some reason, you also can't use: voxel1 = getUniqueEntity();
    bytes32 giftedVoxel = world.tenet_GiftVoxelSystem_giftVoxel(namespace, GrassID);

    VoxelCoord memory coord1 = VoxelCoord(1, 2, 1);
    VoxelCoord memory coord2 = VoxelCoord(2, 1, 2);

    // the build system spawns a new voxel before placing the newly spawned voxel in the world
    bytes32 voxel1 = world.tenet_BuildSystem_build(giftedVoxel, coord1);
    bytes32 voxel2 = world.tenet_BuildSystem_build(giftedVoxel, coord2);

    bytes32[] memory voxels = new bytes32[](2);
    voxels[0] = voxel1;
    voxels[1] = voxel2;

    world.tenet_RegisterCreation_registerCreation("test creation name", "test creation desc", voxels);
    vm.stopPrank();
  }
}
