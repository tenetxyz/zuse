// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { ObjectType, OwnedBy, ObjectEntity } from "@tenet-world/src/codegen/Tables.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";
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
import { NUM_BLOCKS_BEFORE_INCREASE_HEALTH } from "@tenet-simulator/src/Constants.sol";

contract HitTest is MudTest {
  IWorld private world;
  IStore private store;
  IStore private simStore;
  address payable internal alice;
  address payable internal bob;
  VoxelCoord faucetAgentCoord = VoxelCoord(197, 27, 203);
  VoxelCoord initialAgentCoord;
  bytes32 agentObjectTypeId = BuilderObjectID;
  bytes32 faucetObjectEntityId;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    simStore = IStore(SIMULATOR_ADDRESS);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    bob = payable(address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8));
  }

  function setupAgent() internal returns (bytes32, bytes32) {
    bytes32 faucetEntityId = getEntityAtCoord(store, faucetAgentCoord);
    assertTrue(uint256(faucetEntityId) != 0, "Agent not found at coord");
    faucetObjectEntityId = ObjectEntity.get(store, faucetEntityId);

    initialAgentCoord = VoxelCoord(faucetAgentCoord.x, faucetAgentCoord.y, faucetAgentCoord.z - 1);
    bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, agentObjectTypeId, initialAgentCoord);
    assertTrue(uint256(agentEntityId) != 0, "Agent not found at coord");
    bytes32 agentObjectEntityId = ObjectEntity.get(store, agentEntityId);

    return (agentEntityId, agentObjectEntityId);
  }

  function testSingleHit() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    vm.stopPrank();

    vm.startPrank(bob, bob);
    VoxelCoord memory bobAgentCoord = VoxelCoord(faucetAgentCoord.x - 1, faucetAgentCoord.y, faucetAgentCoord.z - 1);
    bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, agentObjectTypeId, bobAgentCoord);
    bytes32 bobAgentObjectEntityId = ObjectEntity.get(store, agentEntityId);
    assertTrue(uint256(bobAgentObjectEntityId) != 0, "Agent not found at coord");

    world.activate(bobAgentObjectEntityId, agentObjectTypeId, bobAgentCoord);

    // Apply hit
    uint256 healthBefore = Health.getHealth(simStore, worldAddress, agentObjectEntityId);
    uint256 bobStaminaBefore = Stamina.getStamina(simStore, worldAddress, bobAgentObjectEntityId);
    world.world_AgentActionSyste_hit(bobAgentObjectEntityId, agentObjectEntityId, 10);
    world.activate(bobAgentObjectEntityId, agentObjectTypeId, bobAgentCoord);
    uint256 healthAfter = Health.getHealth(simStore, worldAddress, agentObjectEntityId);
    uint256 bobStaminaAfter = Stamina.getStamina(simStore, worldAddress, bobAgentObjectEntityId);
    assertTrue(healthAfter < healthBefore, "Health did not decrease");
    assertTrue(bobStaminaAfter < bobStaminaBefore, "Stamina did not decrease");
    vm.stopPrank();

    vm.startPrank(alice, alice);
    vm.roll(block.number + NUM_BLOCKS_BEFORE_INCREASE_HEALTH);
    world.activate(agentObjectEntityId, agentObjectTypeId, initialAgentCoord);
    uint256 healthAfterRecovery = Health.getHealth(simStore, worldAddress, agentObjectEntityId);
    assertTrue(healthAfterRecovery > healthAfter, "Health did not increase after recovery");

    vm.stopPrank();
  }

  function testFatalHit() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    // mine block
    VoxelCoord memory mineCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    bytes32 objectTypeId = world.getTerrainObjectTypeId(mineCoord);
    world.mine(agentObjectEntityId, objectTypeId, mineCoord);
    // get the inventory of the agent
    {
      bytes32[][] memory agentObjects = getKeysWithValue(
        store,
        InventoryTableId,
        Inventory.encode(agentObjectEntityId)
      );
      assertTrue(agentObjects.length == 1, "Agent does not have inventory");
      assertTrue(agentObjects[0].length == 1, "Agent does not have inventory");
      bytes32 agentInventoryId = agentObjects[0][0];
      bytes32 agentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, agentInventoryId);
      assertTrue(agentInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");
    }

    vm.stopPrank();

    vm.startPrank(bob, bob);
    VoxelCoord memory bobAgentCoord = VoxelCoord(faucetAgentCoord.x - 1, faucetAgentCoord.y, faucetAgentCoord.z - 1);
    bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, agentObjectTypeId, bobAgentCoord);
    bytes32 bobAgentObjectEntityId = ObjectEntity.get(store, agentEntityId);
    assertTrue(uint256(bobAgentObjectEntityId) != 0, "Agent not found at coord");

    {
      bytes32[][] memory agentObjects = getKeysWithValue(
        store,
        InventoryTableId,
        Inventory.encode(bobAgentObjectEntityId)
      );
      assertTrue(agentObjects.length == 0, "Agent does not have empty inventory");
    }

    world.activate(bobAgentObjectEntityId, agentObjectTypeId, bobAgentCoord);

    // Apply hit
    uint256 healthBefore = Health.getHealth(simStore, worldAddress, agentObjectEntityId);
    uint256 bobStaminaBefore = Stamina.getStamina(simStore, worldAddress, bobAgentObjectEntityId);
    world.world_AgentActionSyste_hit(bobAgentObjectEntityId, agentObjectEntityId, uint32(healthBefore));
    world.activate(bobAgentObjectEntityId, agentObjectTypeId, bobAgentCoord);
    uint256 healthAfter = Health.getHealth(simStore, worldAddress, agentObjectEntityId);
    uint256 bobStaminaAfter = Stamina.getStamina(simStore, worldAddress, bobAgentObjectEntityId);
    assertTrue(healthAfter == 0, "Health did not decrease");
    assertTrue(bobStaminaAfter < bobStaminaBefore, "Stamina did not decrease");
    assertTrue(ObjectType.get(store, getEntityAtCoord(store, initialAgentCoord)) == AirObjectID, "Agent did not die");

    {
      bytes32[][] memory originalAgentObjects = getKeysWithValue(
        store,
        InventoryTableId,
        Inventory.encode(agentObjectEntityId)
      );
      assertTrue(originalAgentObjects.length == 0, "Agent did not lose inventory");

      bytes32[][] memory agentObjects = getKeysWithValue(
        store,
        InventoryTableId,
        Inventory.encode(bobAgentObjectEntityId)
      );
      assertTrue(agentObjects.length == 1, "Agent does not have inventory");
      assertTrue(agentObjects[0].length == 1, "Agent does not have inventory");
      bytes32 agentInventoryId = agentObjects[0][0];
      bytes32 agentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, agentInventoryId);
      assertTrue(agentInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");
    }

    vm.stopPrank();

    vm.startPrank(alice, alice);

    // claim new agent, should not revert
    setupAgent();

    vm.stopPrank();
  }
}
