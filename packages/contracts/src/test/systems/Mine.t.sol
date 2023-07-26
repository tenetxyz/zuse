// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelType, OwnedBy } from "@tenet-contracts/src/codegen/Tables.sol";

import { GrassVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { VoxelCoord } from "../../Types.sol";
import { Utilities } from "@latticexyz/std-contracts/src/test/Utilities.sol";
import { console } from "forge-std/console.sol";

contract MineTest is MudTest {
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

  function testMineTerrain() public {
    vm.startPrank(alice);
    VoxelCoord memory coord = VoxelCoord({ x: -1598, y: 10, z: 4650 }); // Grass
    console.log("testMineTerrain");

    bytes32 minedEntity = world.mine(GrassVoxelID, coord);

    assertEq(VoxelType.get(store, 1, minedEntity).voxelTypeId, GrassVoxelID);
    assertEq(OwnedBy.get(store, 1, minedEntity), alice);
    vm.stopPrank();
  }
}
