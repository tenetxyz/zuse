// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { ObjectTypeRegistry, ObjectTypeRegistryTableId } from "@tenet-registry/src/codegen/tables/ObjectTypeRegistry.sol";
import { ObjectType, OwnedBy, ObjectEntity } from "@tenet-world/src/codegen/Tables.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { BuilderObjectID, RunnerObjectID, GrassObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { NUM_MAX_INVENTORY_SLOTS } from "@tenet-base-world/src/Constants.sol";

contract BuildMineTest is MudTest {
  IWorld private world;
  IStore private store;
  IStore private registryStore;
  IStore private simStore;
  address payable internal alice;
  VoxelCoord faucetAgentCoord = VoxelCoord(197, 27, 203);
  VoxelCoord initialAgentCoord;
  bytes32 agentObjectTypeId = RunnerObjectID;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    registryStore = IStore(REGISTRY_ADDRESS);
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

  function testSingleMineBuild() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory mineCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    bytes32 objectTypeId = world.getTerrainObjectTypeId(mineCoord);
    world.mine(agentObjectEntityId, objectTypeId, mineCoord);
    // get the inventory of the agent
    bytes32[][] memory agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 1, "Agent does not have inventory");
    assertTrue(agentObjects[0].length == 1, "Agent does not have inventory");
    bytes32 agentInventoryId = agentObjects[0][0];
    bytes32 agentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, agentInventoryId);
    assertTrue(agentInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");
    assertTrue(
      InventoryObject.getNumObjects(store, agentInventoryId) == 1,
      "Agent does not have correct number of mined objects in inventory"
    );

    VoxelCoord memory buildCoord = VoxelCoord(initialAgentCoord.x - 1, initialAgentCoord.y, initialAgentCoord.z - 1);
    world.build(agentObjectEntityId, objectTypeId, buildCoord, agentInventoryId);
    bytes32 buildEntityId = getEntityAtCoord(store, buildCoord);
    assertTrue(uint256(buildEntityId) != 0, "Build object not found at coord");
    assertTrue(ObjectType.get(store, buildEntityId) == objectTypeId, "Build object not of correct type");
    agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 0, "Agent still has inventory");

    // Mine the build object
    world.mine(agentObjectEntityId, objectTypeId, buildCoord);
    agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 1, "Agent does not have inventory");
    assertTrue(agentObjects[0].length == 1, "Agent does not have inventory");
    agentInventoryId = agentObjects[0][0];
    agentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, agentInventoryId);
    assertTrue(agentInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");
    assertTrue(
      InventoryObject.getNumObjects(store, agentInventoryId) == 1,
      "Agent does not have correct number of mined objects in inventory"
    );

    vm.stopPrank();
  }

  function testDoubleMineBuild() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory mineCoord1 = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    VoxelCoord memory mineCoord2 = VoxelCoord(
      initialAgentCoord.x - 1,
      initialAgentCoord.y - 1,
      initialAgentCoord.z - 1
    );
    bytes32 objectTypeId1 = world.getTerrainObjectTypeId(mineCoord1);
    world.mine(agentObjectEntityId, objectTypeId1, mineCoord1);
    bytes32 objectTypeId2 = world.getTerrainObjectTypeId(mineCoord2);
    world.mine(agentObjectEntityId, objectTypeId2, mineCoord2);
    assertTrue(objectTypeId1 == objectTypeId2, "Mined objects are not the same");
    // get the inventory of the agent
    bytes32[][] memory agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 1, "Agent does not have inventory");
    assertTrue(agentObjects[0].length == 1, "Agent does not have inventory");
    bytes32 agentInventoryId1 = agentObjects[0][0];
    bytes32 agentInventoryObjectTypeId1 = InventoryObject.getObjectTypeId(store, agentInventoryId1);
    assertTrue(agentInventoryObjectTypeId1 == objectTypeId1, "Agent does not have mined object in inventory");
    assertTrue(
      InventoryObject.getNumObjects(store, agentInventoryId1) == 2,
      "Agent does not have correct number of mined objects in inventory"
    );

    VoxelCoord memory newAgentCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z - 1);
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, newAgentCoord);

    {
      VoxelCoord memory buildCoord1 = VoxelCoord(newAgentCoord.x - 1, newAgentCoord.y, newAgentCoord.z - 1);
      world.build(agentObjectEntityId, objectTypeId1, buildCoord1, agentInventoryId1);

      agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
      assertTrue(agentObjects.length == 1, "Agent still has inventory");

      VoxelCoord memory buildCoord2 = VoxelCoord(newAgentCoord.x - 1, newAgentCoord.y + 1, newAgentCoord.z - 1);
      world.build(agentObjectEntityId, objectTypeId1, buildCoord2, agentInventoryId1);

      bytes32 buildEntityId1 = getEntityAtCoord(store, buildCoord1);
      assertTrue(uint256(buildEntityId1) != 0, "Build object not found at coord");
      assertTrue(ObjectType.get(store, buildEntityId1) == objectTypeId1, "Build object not of correct type");

      bytes32 buildEntityId2 = getEntityAtCoord(store, buildCoord2);
      assertTrue(uint256(buildEntityId2) != 0, "Build object not found at coord");
      assertTrue(ObjectType.get(store, buildEntityId2) == objectTypeId2, "Build object not of correct type");
    }

    agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 0, "Agent still has inventory");

    vm.stopPrank();
  }

  function testBuildWithoutBlock() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory buildCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z - 1);

    vm.expectRevert();
    world.build(agentObjectEntityId, GrassObjectID, buildCoord);

    vm.stopPrank();
  }

  function testMultipleStack() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory mineCoord1 = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    VoxelCoord memory mineCoord2 = VoxelCoord(
      initialAgentCoord.x - 1,
      initialAgentCoord.y - 1,
      initialAgentCoord.z - 1
    );
    bytes32 objectTypeId1 = world.getTerrainObjectTypeId(mineCoord1);

    ObjectTypeRegistry.setStackable(registryStore, objectTypeId1, 1);

    world.mine(agentObjectEntityId, objectTypeId1, mineCoord1);

    bytes32 objectTypeId2 = world.getTerrainObjectTypeId(mineCoord2);
    world.mine(agentObjectEntityId, objectTypeId2, mineCoord2);
    assertTrue(objectTypeId1 == objectTypeId2, "Mined objects are not the same");

    // get the inventory of the agent
    bytes32[][] memory agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 2, "Agent does not have inventory");
    assertTrue(agentObjects[0].length == 1, "Agent does not have inventory");
    bytes32 agentInventoryId1 = agentObjects[0][0];
    bytes32 agentInventoryObjectTypeId1 = InventoryObject.getObjectTypeId(store, agentInventoryId1);
    assertTrue(agentInventoryObjectTypeId1 == objectTypeId1, "Agent does not have mined object in inventory");
    assertTrue(
      InventoryObject.getNumObjects(store, agentInventoryId1) == 1,
      "Agent does not have correct number of mined objects in inventory"
    );
    assertTrue(agentObjects[1].length == 1, "Agent does not have inventory");
    bytes32 agentInventoryId2 = agentObjects[1][0];
    bytes32 agentInventoryObjectTypeId2 = InventoryObject.getObjectTypeId(store, agentInventoryId2);
    assertTrue(agentInventoryObjectTypeId2 == objectTypeId2, "Agent does not have mined object in inventory");
    assertTrue(
      InventoryObject.getNumObjects(store, agentInventoryId2) == 1,
      "Agent does not have correct number of mined objects in inventory"
    );

    vm.stopPrank();
  }

  function testFullInventory() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory mineCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    bytes32 objectTypeId = world.getTerrainObjectTypeId(mineCoord);
    ObjectTypeRegistry.setStackable(registryStore, objectTypeId, 1);

    bytes32 inventoryId;
    for (uint i = 0; i < NUM_MAX_INVENTORY_SLOTS; i++) {
      inventoryId = getUniqueEntity();
      Inventory.set(inventoryId, agentObjectEntityId);
      ObjectProperties memory objectProperties;
      InventoryObject.set(inventoryId, objectTypeId, 1, abi.encode(objectProperties));
    }

    vm.expectRevert();
    world.mine(agentObjectEntityId, objectTypeId, mineCoord);

    world.build(
      agentObjectEntityId,
      objectTypeId,
      VoxelCoord(initialAgentCoord.x, initialAgentCoord.y + 1, initialAgentCoord.z + 1),
      inventoryId
    );

    world.mine(agentObjectEntityId, objectTypeId, mineCoord);

    vm.stopPrank();
  }
}
