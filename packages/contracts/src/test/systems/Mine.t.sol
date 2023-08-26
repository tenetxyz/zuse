// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelType, OwnedBy } from "@tenet-contracts/src/codegen/Tables.sol";

import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { VoxelCoord } from "../../Types.sol";
import { console } from "forge-std/console.sol";

contract MineTest is MudTest {
  IWorld private world;
  IStore private store;

  address payable internal alice;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
  }
}
