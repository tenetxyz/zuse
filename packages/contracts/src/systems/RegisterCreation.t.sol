// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { Deploy } from "../Deploy.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { addressToEntity } from "solecs/utils.sol";
import { BuildSystem, ID as BuildSystemID } from "../../systems/BuildSystem.sol";
import { TransitionRule } from "../../types.sol";
import { TypeComponent, ID as TypeComponentID } from "../../components/TypeComponent.sol";
import { VoxelCoord } from "../../types.sol";

contract RegisterCreationTest is MudV2Test {
  constructor() MudTest(new Deploy()) {}

  IWorld private world;
  IStore private store;
  address payable internal alice;

  bytes32 voxel1;
  bytes32 voxel2;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);

    alice = utils.getNextUserAddress();

    vm.startPrank(deployer);

    // Give two voxels to alice
    voxel1 = world.getUniqueEntityId();
    Item.set(voxel1, voxelTypeId);
    OwnedBy.set(voxel1, addressToEntity(alice));

    voxel2 = world.getUniqueEntityId();
    Item.set(voxel2, voxelTypeId);
    OwnedBy.set(voxel2, addressToEntity(alice));
    vm.stopPrank();
  }

  function testRegisterCreation() public {
    vm.startPrank(alice);
    VoxelCoord memory coord1 = new VoxelCoord(1, 2, 1);
    VoxelCoord memory coord2 = new VoxelCoord(2, 1, 2);
    world.build(voxel1, coord1);
    world.build(voxel2, coord2);

    world.registerCreation("test creation name", coord1, coord2);
    vm.stopPrank();
  }
}
