// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { VoxelCoord, BaseCreationInWorld, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { OwnedBy, VoxelType } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelTypeData } from "@tenet-utils/src/Types.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { ElectronVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { SignalSourceVoxelID, SignalVoxelID } from "@tenet-level2-ca-extensions-1/src/Constants.sol";

contract TruthTableClassifyTest is MudTest {
  IWorld private world;
  IStore private store;

  address payable internal alice;
  bytes16 namespace;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
  }

  function registerOnTable() private {
    uint256[] memory inputRows = new uint256[](1);
    inputRows[0] = 1;
    uint256[] memory outputRows = new uint256[](1);
    outputRows[0] = 1;
    world.registerTruthTable("onTable", "desc", inputRows, outputRows, 1, 1);
  }

  // just test that we can register the truth table
  function testRegisterTruthTable() public {
    vm.startPrank(alice);
    registerOnTable();
    vm.stopPrank();
  }

  // This test isn't complete yet. see the TODO at the bottom
  function testClassifyLogicGate() public {
    vm.startPrank(alice);

    registerOnTable();

    bytes32 giftedSignalSource = world.giftVoxel(SignalSourceVoxelID);
    bytes32 giftedSignal = world.giftVoxel(SignalVoxelID);

    VoxelCoord memory coord1 = VoxelCoord(1, 2, 1);
    VoxelCoord memory coord2 = VoxelCoord(2, 1, 2);

    VoxelEntity memory agentEntity;

    VoxelEntity memory voxel1Entity = world.buildWithAgent(SignalSourceVoxelID, coord1, agentEntity, bytes4(0));
    VoxelEntity memory voxel2Entity = world.buildWithAgent(SignalVoxelID, coord2, agentEntity, bytes4(0));

    VoxelEntity[] memory voxels = new VoxelEntity[](2);
    voxels[0] = voxel1Entity;
    voxels[1] = voxel2Entity;

    // TODO: fix registering the creation
    // BaseCreationInWorld[] memory baseCreationsInWorld = new BaseCreationInWorld[](0);
    // world.registerCreation("onGate", "a simple gate to test the truth table classifier", voxels, baseCreationsInWorld);

    // TODO: classify this creation
    vm.stopPrank();
  }
}
