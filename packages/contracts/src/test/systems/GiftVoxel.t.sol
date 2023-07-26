// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelType, OwnedBy } from "@tenet-contracts/src/codegen/Tables.sol";

import { AirVoxelID, GrassVoxelID, DirtVoxelID } from "@tenet-base-ca/src/Constants.sol";

import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { VoxelCoord } from "../../Types.sol";
import { Utilities } from "@latticexyz/std-contracts/src/test/Utilities.sol";
import { console } from "forge-std/console.sol";

contract GiftVoxelTest is MudTest {
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

  function testNumUniqueVoxelTypesIOwn() public {
    vm.startPrank(alice);
    bytes32 giftedVoxel = world.giftVoxel(GrassVoxelID);
    require(OwnedBy.get(store, giftedVoxel) == addressToEntityKey(alice), "Alice should own the voxel");
    require(world.numUniqueVoxelTypesIOwn() == 1, "Alice should own 1 unique voxel type");
    world.giftVoxel(AirVoxelID);
    require(world.numUniqueVoxelTypesIOwn() == 2, "Alice should own 2 unique voxel types");
    world.giftVoxel(AirVoxelID);
    require(
      world.numUniqueVoxelTypesIOwn() == 2,
      "Alice should own 2 unique voxel types, after gifting a duplicate voxel type"
    );
    world.giftVoxel(DirtVoxelID);
    require(world.numUniqueVoxelTypesIOwn() == 3, "Alice should own 3 unique voxel types");
    vm.stopPrank();
  }
}
