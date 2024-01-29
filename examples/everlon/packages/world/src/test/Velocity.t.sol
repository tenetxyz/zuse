// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ObjectType, OwnedBy, ObjectEntity } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { BuilderObjectID, RunnerObjectID, GrassObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

contract VelocityTest is MudTest {
  IWorld private world;
  IStore private store;
  IStore private simStore;
  address payable internal alice;
  VoxelCoord faucetAgentCoord = VoxelCoord(197, 27, 203);
  VoxelCoord initialAgentCoord;
  bytes32 agentObjectTypeId = RunnerObjectID;

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

  function testMovingUp() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);

    // move in z direction
    VoxelCoord memory newAgentCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z - 1);
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, newAgentCoord);
    uint256 staminaUsed = staminaBefore - Stamina.get(simStore, worldAddress, agentObjectEntityId);
    assertTrue(staminaUsed > 0, "Stamina not used");

    // move block from ground up one
    VoxelCoord memory oldCoord = VoxelCoord(newAgentCoord.x + 1, newAgentCoord.y - 1, newAgentCoord.z - 1);
    VoxelCoord memory newCoord = VoxelCoord(oldCoord.x - 1, oldCoord.y + 1, oldCoord.z);
    bytes32 belowEntityId = getEntityAtCoord(store, oldCoord);
    bytes32 objectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    oldCoord = VoxelCoord(newAgentCoord.x - 1, newAgentCoord.y - 1, newAgentCoord.z - 1);
    newCoord = VoxelCoord(oldCoord.x, oldCoord.y + 1, oldCoord.z);
    belowEntityId = getEntityAtCoord(store, oldCoord);
    objectTypeId = ObjectType.get(store, belowEntityId);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);

    oldCoord = newCoord;
    newCoord = VoxelCoord(oldCoord.x + 1, oldCoord.y + 1, oldCoord.z);
    world.move(agentObjectEntityId, objectTypeId, oldCoord, newCoord);
    belowEntityId = getEntityAtCoord(store, newCoord);
    assertTrue(ObjectType.get(store, belowEntityId) == objectTypeId, "Block not moved");
    Mass.set(simStore, worldAddress, ObjectEntity.get(store, belowEntityId), 50);

    // Now I can move self up
    VoxelCoord memory oldAgentCoord = newAgentCoord;
    newAgentCoord = VoxelCoord(newAgentCoord.x, newAgentCoord.y + 1, newAgentCoord.z);
    staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));
    world.move(agentObjectEntityId, agentObjectTypeId, oldAgentCoord, newAgentCoord);
    // make sure agent didnt fall
    assertTrue(ObjectEntity.get(store, getEntityAtCoord(store, newAgentCoord)) == agentObjectEntityId, "Agent fell");

    uint256 staminaUsedForMovingUp = staminaBefore - Stamina.get(simStore, worldAddress, agentObjectEntityId);
    // should cost more than moving in z
    assertTrue(staminaUsedForMovingUp > staminaUsed, "Stamina not greater");

    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));
    // move down, should cost less
    oldAgentCoord = newAgentCoord;
    newAgentCoord = VoxelCoord(newAgentCoord.x, newAgentCoord.y - 1, newAgentCoord.z);
    staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(agentObjectEntityId, agentObjectTypeId, oldAgentCoord, newAgentCoord);
    uint256 staminaUsedForMovingDown = staminaBefore - Stamina.get(simStore, worldAddress, agentObjectEntityId);
    assertTrue(staminaUsedForMovingDown < staminaUsedForMovingUp, "Stamina not less");

    vm.stopPrank();
  }
}
