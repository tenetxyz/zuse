// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { IWorld } from "../../codegen/world/IWorld.sol";
import { Powered, PoweredTableId } from "../../codegen/Tables.sol";

contract PoweredSystemTest is MudV2Test {
  IWorld public world;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
  }

  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testEventHandler() public {
    bytes32 centerEntityId = bytes32(uint256(1));
    bytes32[] memory neighbourEntityIds = new bytes32[](6);

    world.dhvani_PoweredSystem_eventHandler(centerEntityId, neighbourEntityIds);

     // assertEq(counter, 2);
  }
}