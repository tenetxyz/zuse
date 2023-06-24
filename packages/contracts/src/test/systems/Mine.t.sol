// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import { VoxelType, OwnedBy } from "../../codegen/Tables.sol";

import { GrassID } from "../../prototypes/Voxels.sol";
import { addressToEntityKey } from "../../utils.sol";
import { VoxelCoord } from "../../types.sol";
import { Utilities } from "@latticexyz/std-contracts/src/test/Utilities.sol";
import { console } from "forge-std/console.sol";

contract MineTest is MudV2Test {
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

    bytes32 minedEntity = world.tenet_MineSystem_mine(coord, GrassID, bytes16("tenet"), bytes32(keccak256("dirt")));

    assertEq(VoxelType.get(store, minedEntity).voxelType, GrassID);
    assertEq(OwnedBy.get(store, minedEntity), addressToEntityKey(alice));
    vm.stopPrank();
  }

}
