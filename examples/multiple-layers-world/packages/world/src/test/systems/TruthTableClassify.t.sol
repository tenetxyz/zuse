// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { VoxelCoord, BaseCreationInWorld, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { OwnedBy, VoxelType, VoxelTypeData } from "@tenet-world/src/codegen/Tables.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";
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

    alice = utils.getNextUserAddress();
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

    (uint32 scaleVoxel1, bytes32 voxel1) = world.build(1, giftedSignalSource, coord1, bytes4(0));
    (uint32 scaleVoxel2, bytes32 voxel2) = world.build(1, giftedSignal, coord2, bytes4(0));

    VoxelEntity[] memory voxels = new VoxelEntity[](2);
    voxels[0] = VoxelEntity({ scale: scaleVoxel1, entityId: voxel1 });
    voxels[1] = VoxelEntity({ scale: scaleVoxel2, entityId: voxel2 });

    // TODO: fix registering the creation
    // BaseCreationInWorld[] memory baseCreationsInWorld = new BaseCreationInWorld[](0);
    // world.registerCreation("onGate", "a simple gate to test the truth table classifier", voxels, baseCreationsInWorld);

    // TODO: classify this creation
    vm.stopPrank();
  }
}
