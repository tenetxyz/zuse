// SPDX-License-Identifier: MIT
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
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

contract GravityTest is MudTest {
  IWorld private world;
  IStore private store;
  IStore private simStore;
  address payable internal alice;
  VoxelCoord faucetAgentCoord = VoxelCoord(197, 27, 203);
  VoxelCoord initialAgentCoord;
  bytes32 agentObjectTypeId = BuilderObjectID;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    simStore = IStore(SIMULATOR_ADDRESS);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
  }

  function setupAgent() internal returns (bytes32, bytes32) {
    bytes32 faucetEntityId = getEntityAtCoord(store, faucetAgentCoord);
    assertTrue(uint256(faucetEntityId) != 0, "Agent not found at coord");
    bytes32 faucetObjectEntityId = ObjectEntity.get(store, faucetEntityId);

    initialAgentCoord = VoxelCoord(faucetAgentCoord.x, faucetAgentCoord.y, faucetAgentCoord.z - 1);
    bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, agentObjectTypeId, initialAgentCoord);
    assertTrue(uint256(agentEntityId) != 0, "Agent not found at coord");
    bytes32 agentObjectEntityId = ObjectEntity.get(store, agentEntityId);

    return (agentEntityId, agentObjectEntityId);
  }

  function testBottomSupport() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();
    VoxelCoord memory newCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z - 1);
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, newCoord);

    // Assert that the agent is at the new coord
    bytes32 newEntityId = getEntityAtCoord(store, newCoord);
    bytes32 newCoordObjectEntityId = ObjectEntity.get(store, newEntityId);
    assertTrue(newCoordObjectEntityId == agentObjectEntityId, "Agent not moved");
    assertTrue(ObjectType.get(store, newEntityId) == agentObjectTypeId, "Agent not moved");

    vm.stopPrank();
  }

  function testNeighbourFall() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    // move agent away from faucet
    VoxelCoord memory newAgentCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z - 1);
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, newAgentCoord);

    // move block underneath agent
    VoxelCoord memory oldCoord = VoxelCoord(newAgentCoord.x, newAgentCoord.y - 1, newAgentCoord.z);
    VoxelCoord memory newCoord = VoxelCoord(oldCoord.x + 1, oldCoord.y + 1, oldCoord.z);
    bytes32 belowEntityId = getEntityAtCoord(store, oldCoord);
    bytes32 belowObjectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, belowObjectTypeId, oldCoord, newCoord);

    // Assert that the agent is at the old coord, ie it fell
    bytes32 newEntityId = getEntityAtCoord(store, oldCoord);
    bytes32 newCoordObjectEntityId = ObjectEntity.get(store, newEntityId);
    assertTrue(newCoordObjectEntityId == agentObjectEntityId, "Agent didnt fall");
    assertTrue(ObjectType.get(store, newEntityId) == agentObjectTypeId, "Agent didnt fall");

    vm.stopPrank();
  }

  function testFall() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    // move block from ground up one
    VoxelCoord memory oldCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    VoxelCoord memory newCoord = VoxelCoord(oldCoord.x, oldCoord.y + 1, oldCoord.z);
    bytes32 belowEntityId = getEntityAtCoord(store, oldCoord);
    bytes32 objectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    // Object should not fall because it's beside the agent
    bytes32 oldEntityId = getEntityAtCoord(store, oldCoord);
    assertTrue(ObjectType.get(store, oldEntityId) == AirObjectID, "Object did fall");
    bytes32 newEntityId = getEntityAtCoord(store, newCoord);
    assertTrue(ObjectType.get(store, newEntityId) == objectTypeId, "Object did fall");

    oldCoord = newCoord;
    newCoord = VoxelCoord(newCoord.x - 1, newCoord.y + 1, newCoord.z);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    // Assert that the object is at the old coord, ie it fell
    bytes32 fallenEntityId = getEntityAtCoord(store, VoxelCoord(newCoord.x, newCoord.y - 1, newCoord.z));
    assertTrue(ObjectType.get(store, fallenEntityId) == objectTypeId, "Object didnt fall");
    oldEntityId = getEntityAtCoord(store, newCoord);
    assertTrue(ObjectType.get(store, oldEntityId) == AirObjectID, "Object didnt fall");
    newEntityId = getEntityAtCoord(store, newCoord);
    assertTrue(ObjectType.get(store, newEntityId) == AirObjectID, "Object didnt fall");

    vm.stopPrank();
  }

  function testSideSupport() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    // move block from ground up one
    VoxelCoord memory oldCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    VoxelCoord memory newCoord = VoxelCoord(oldCoord.x, oldCoord.y + 1, oldCoord.z);
    bytes32 belowEntityId = getEntityAtCoord(store, oldCoord);
    bytes32 objectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    // Object should not fall because it's beside the agent
    bytes32 oldEntityId = getEntityAtCoord(store, oldCoord);
    assertTrue(ObjectType.get(store, oldEntityId) == AirObjectID, "Object did fall");
    bytes32 newEntityId = getEntityAtCoord(store, newCoord);
    assertTrue(ObjectType.get(store, newEntityId) == objectTypeId, "Object did fall");

    vm.stopPrank();
  }

  function testFallWithWeakSideSupport() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    // move agent away from faucet
    VoxelCoord memory newAgentCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z - 1);
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, newAgentCoord);

    // move block from ground up one
    VoxelCoord memory oldCoord = VoxelCoord(newAgentCoord.x, newAgentCoord.y - 1, newAgentCoord.z - 1);
    VoxelCoord memory newCoord = VoxelCoord(oldCoord.x, oldCoord.y + 1, oldCoord.z);
    bytes32 belowEntityId = getEntityAtCoord(store, oldCoord);
    bytes32 objectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    // Object should not fall because it's beside the agent
    bytes32 oldEntityId = getEntityAtCoord(store, oldCoord);
    assertTrue(ObjectType.get(store, oldEntityId) == AirObjectID, "Object did fall");
    bytes32 newEntityId = getEntityAtCoord(store, newCoord);
    assertTrue(ObjectType.get(store, newEntityId) == objectTypeId, "Object did fall");

    // move block underneath agent
    oldCoord = VoxelCoord(newAgentCoord.x, newAgentCoord.y - 1, newAgentCoord.z);
    newCoord = VoxelCoord(oldCoord.x + 1, oldCoord.y + 1, oldCoord.z);
    belowEntityId = getEntityAtCoord(store, oldCoord);
    bytes32 belowObjectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, belowObjectTypeId, oldCoord, newCoord);

    // Assert that the agent is at the old coord, ie it fell even though beside a block
    newEntityId = getEntityAtCoord(store, oldCoord);
    bytes32 newCoordObjectEntityId = ObjectEntity.get(store, newEntityId);
    assertTrue(newCoordObjectEntityId == agentObjectEntityId, "Agent didnt fall");
    assertTrue(ObjectType.get(store, newEntityId) == agentObjectTypeId, "Agent didnt fall");

    vm.stopPrank();
  }

  function testSideSupportMoves() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    // move block from ground up one
    VoxelCoord memory oldCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    VoxelCoord memory newCoord = VoxelCoord(oldCoord.x, oldCoord.y + 1, oldCoord.z);
    bytes32 belowEntityId = getEntityAtCoord(store, oldCoord);
    bytes32 objectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    // Object should not fall because it's beside the agent
    bytes32 oldEntityId = getEntityAtCoord(store, oldCoord);
    assertTrue(ObjectType.get(store, oldEntityId) == AirObjectID, "Object did fall");
    bytes32 newEntityId = getEntityAtCoord(store, newCoord);
    assertTrue(ObjectType.get(store, newEntityId) == objectTypeId, "Object did fall");

    // move agent away
    VoxelCoord memory newAgentCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y, initialAgentCoord.z);
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, newAgentCoord);

    // Object should have fallen
    oldEntityId = getEntityAtCoord(store, oldCoord);
    assertTrue(ObjectType.get(store, oldEntityId) == objectTypeId, "Object didnt fall");
    newEntityId = getEntityAtCoord(store, newCoord);
    assertTrue(ObjectType.get(store, newEntityId) == AirObjectID, "Object didnt fall");

    vm.stopPrank();
  }

  function testFallDouble() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    // move block from ground up one
    VoxelCoord memory oldCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    VoxelCoord memory newCoord = VoxelCoord(oldCoord.x - 1, oldCoord.y + 1, oldCoord.z);
    bytes32 belowEntityId = getEntityAtCoord(store, oldCoord);
    bytes32 objectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    oldCoord = VoxelCoord(initialAgentCoord.x - 1, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    newCoord = VoxelCoord(oldCoord.x, oldCoord.y + 1, oldCoord.z);
    belowEntityId = getEntityAtCoord(store, oldCoord);
    objectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    oldCoord = newCoord;
    newCoord = VoxelCoord(oldCoord.x + 1, oldCoord.y + 1, oldCoord.z);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    oldCoord = VoxelCoord(initialAgentCoord.x - 1, initialAgentCoord.y - 1, initialAgentCoord.z);
    newCoord = VoxelCoord(oldCoord.x, oldCoord.y + 1, oldCoord.z);
    belowEntityId = getEntityAtCoord(store, oldCoord);
    objectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    // Set mass of blocks to low mass
    belowEntityId = getEntityAtCoord(store, newCoord);
    Mass.set(simStore, worldAddress, ObjectEntity.get(store, belowEntityId), 50);

    oldCoord = newCoord;
    newCoord = VoxelCoord(oldCoord.x, oldCoord.y + 1, oldCoord.z - 1);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    // Should fall two blocks
    belowEntityId = getEntityAtCoord(store, VoxelCoord(newCoord.x, newCoord.y - 2, newCoord.z));
    assertTrue(ObjectType.get(store, belowEntityId) == objectTypeId, "Object didnt fall");

    vm.stopPrank();
  }
}
