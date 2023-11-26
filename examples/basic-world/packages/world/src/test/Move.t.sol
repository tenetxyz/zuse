// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ObjectType, OwnedBy, ObjectEntity } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { BuilderObjectID, GrassObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";

contract MoveTest is MudTest {
  IWorld private world;
  IStore private store;
  VoxelCoord initialAgentCoord = VoxelCoord(50, 10, 50);

  address payable internal alice;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
  }

  function testMoveSelf() public {
    vm.startPrank(alice, alice);

    bytes32 initialAgentEntityId = getEntityAtCoord(store, initialAgentCoord);
    assertTrue(uint256(initialAgentEntityId) != 0, "Agent not found at coord");
    bytes32 agentObjectTypeId = ObjectType.get(store, initialAgentEntityId);

    world.claimAgent(initialAgentEntityId);

    bytes32 agentObjectEntityId = ObjectEntity.get(store, initialAgentEntityId);

    VoxelCoord memory newCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y, initialAgentCoord.z);
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, newCoord);
    bytes32 newEntityId = getEntityAtCoord(store, newCoord);
    bytes32 newCoordObjectEntityId = ObjectEntity.get(store, newEntityId);
    assertTrue(newCoordObjectEntityId == agentObjectEntityId, "Agent not moved");
    assertTrue(ObjectType.get(store, newEntityId) == agentObjectTypeId, "Agent not moved");

    vm.stopPrank();
  }

  function testMoveSelfTooFar() public {
    vm.startPrank(alice, alice);

    bytes32 initialAgentEntityId = getEntityAtCoord(store, initialAgentCoord);
    assertTrue(uint256(initialAgentEntityId) != 0, "Agent not found at coord");
    bytes32 agentObjectTypeId = ObjectType.get(store, initialAgentEntityId);

    world.claimAgent(initialAgentEntityId);

    bytes32 agentObjectEntityId = ObjectEntity.get(store, initialAgentEntityId);

    vm.expectRevert();
    VoxelCoord memory newCoord = VoxelCoord(initialAgentCoord.x + 2, initialAgentCoord.y, initialAgentCoord.z);
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, newCoord);

    vm.stopPrank();
  }
}
