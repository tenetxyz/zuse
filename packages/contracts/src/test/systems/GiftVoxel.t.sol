// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import { VoxelType, OwnedBy } from "../../codegen/Tables.sol";

import { GrassID, AirID, DirtID } from "../../prototypes/Voxels.sol";
import { addressToEntityKey } from "../../utils.sol";
import { VoxelCoord } from "../../types.sol";
import { Utilities } from "@latticexyz/std-contracts/src/test/Utilities.sol";
import { console } from "forge-std/console.sol";

contract GiftVoxelTest is MudV2Test {
    IWorld private world;
    IStore private store;
    Utilities internal immutable utils = new Utilities();

    address payable internal alice;
    bytes16 namespace;

    function setUp() public override {
        super.setUp();
        world = IWorld(worldAddress);
        store = IStore(worldAddress);
        namespace = bytes16("tenet");

        alice = utils.getNextUserAddress();
    }

    function testNumUniqueVoxelTypesIOwn() public {
        vm.startPrank(alice);
        bytes32 giftedVoxel = world.tenet_GiftVoxelSystem_giftVoxel(namespace, GrassID);
        require(OwnedBy.get(store, giftedVoxel) == addressToEntityKey(alice), "Alice should own the voxel");
        require(world.tenet_GiftVoxelSystem_numUniqueVoxelTypesIOwn() == 1, "Alice should own 1 unique voxel type");
        world.tenet_GiftVoxelSystem_giftVoxel(namespace, AirID);
        require(world.tenet_GiftVoxelSystem_numUniqueVoxelTypesIOwn() == 2, "Alice should own 2 unique voxel types");
        world.tenet_GiftVoxelSystem_giftVoxel(namespace, AirID);
        require(world.tenet_GiftVoxelSystem_numUniqueVoxelTypesIOwn() == 2, "Alice should own 2 unique voxel types, after gifting a duplicate voxel type");
        world.tenet_GiftVoxelSystem_giftVoxel(namespace, DirtID);
        require(world.tenet_GiftVoxelSystem_numUniqueVoxelTypesIOwn() == 3, "Alice should own 3 unique voxel types");
        vm.stopPrank();
    }

}
