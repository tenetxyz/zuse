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
import { BuilderObjectID, RunnerObjectID, GrassObjectID, AirObjectID, WoodenPickObjectID, ChestObjectID, MAX_CHEST_SLOTS } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { NUM_MAX_INVENTORY_SLOTS } from "@tenet-base-world/src/Constants.sol";

contract InventoryTest is MudTest {
  IWorld private world;
  IStore private store;
  IStore private registryStore;
  IStore private simStore;
  address payable internal alice;
  address payable internal bob;
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
    bob = payable(address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8));
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
      InventoryObject.set(inventoryId, objectTypeId, 1, 1, abi.encode(objectProperties));
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

  function testDurability() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    bytes32 inventoryId = getUniqueEntity();
    Inventory.set(inventoryId, agentObjectEntityId);
    ObjectProperties memory objectProperties;
    InventoryObject.set(inventoryId, WoodenPickObjectID, 1, 2, abi.encode(objectProperties));

    VoxelCoord memory mineCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    bytes32 objectTypeId = world.getTerrainObjectTypeId(mineCoord);

    world.equip(agentObjectEntityId, inventoryId);

    world.mine(agentObjectEntityId, objectTypeId, mineCoord);

    // Check if the durability is reduced
    assertTrue(InventoryObject.getNumUsesLeft(store, inventoryId) == 1, "Durability is not reduced");

    mineCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    objectTypeId = world.getTerrainObjectTypeId(mineCoord);
    world.mine(agentObjectEntityId, objectTypeId, mineCoord);

    // Check if item is destroyed
    bytes32[][] memory agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    for (uint i = 0; i < agentObjects.length; i++) {
      bytes32 inventoryId = agentObjects[i][0];
      bytes32 inventoryObjectTypeId = InventoryObject.getObjectTypeId(store, inventoryId);
      assertTrue(inventoryObjectTypeId != WoodenPickObjectID, "Item is not destroyed");
    }

    vm.stopPrank();
  }

  function testDropItemIntoAirAndPickUp() public {
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

    VoxelCoord memory dropCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y, initialAgentCoord.z + 1);
    assertTrue(world.getTerrainObjectTypeId(dropCoord) == AirObjectID, "Drop coord is not air");
    world.transfer(agentObjectEntityId, dropCoord, agentInventoryId, 1);
    bytes32 dropEntityId = getEntityAtCoord(store, dropCoord);
    assertTrue(uint256(dropEntityId) != 0, "Drop entity not found at coord");
    bytes32 dropObjectEntityId = ObjectEntity.get(store, dropEntityId);
    assertTrue(dropObjectEntityId != bytes32(0), "Drop entity not found at coord");

    // get the inventory of the agent
    agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 0, "Agent has inventory");

    bytes32[][] memory airObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(dropObjectEntityId));
    assertTrue(airObjects.length == 1, "Air does not have inventory");
    assertTrue(airObjects[0].length == 1, "Air does not have inventory");
    bytes32 airInventoryId = airObjects[0][0];
    bytes32 airInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, airInventoryId);
    assertTrue(airInventoryObjectTypeId == objectTypeId, "Air does not have mined object in inventory");
    assertTrue(
      InventoryObject.getNumObjects(store, airInventoryId) == 1,
      "Air does not have correct number of mined objects in inventory"
    );

    // Move into the air and pick up the item
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, dropCoord);
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

    airObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(dropObjectEntityId));
    assertTrue(airObjects.length == 0, "Air has inventory");

    vm.stopPrank();
  }

  function testTransferTooFar() public {
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

    VoxelCoord memory dropCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y, initialAgentCoord.z + 3);
    assertTrue(world.getTerrainObjectTypeId(dropCoord) == AirObjectID, "Drop coord is not air");

    vm.expectRevert();
    world.transfer(agentObjectEntityId, dropCoord, agentInventoryId, 1);

    vm.stopPrank();
  }

  function testPickupFullInventory() public {
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

    VoxelCoord memory dropCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y, initialAgentCoord.z + 1);
    assertTrue(world.getTerrainObjectTypeId(dropCoord) == AirObjectID, "Drop coord is not air");
    world.transfer(agentObjectEntityId, dropCoord, agentInventoryId, 1);
    bytes32 dropEntityId = getEntityAtCoord(store, dropCoord);
    assertTrue(uint256(dropEntityId) != 0, "Drop entity not found at coord");
    bytes32 dropObjectEntityId = ObjectEntity.get(store, dropEntityId);
    assertTrue(dropObjectEntityId != bytes32(0), "Drop entity not found at coord");

    // get the inventory of the agent
    agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 0, "Agent has inventory");

    bytes32[][] memory airObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(dropObjectEntityId));
    assertTrue(airObjects.length == 1, "Air does not have inventory");
    assertTrue(airObjects[0].length == 1, "Air does not have inventory");
    bytes32 airInventoryId = airObjects[0][0];
    bytes32 airInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, airInventoryId);
    assertTrue(airInventoryObjectTypeId == objectTypeId, "Air does not have mined object in inventory");
    assertTrue(
      InventoryObject.getNumObjects(store, airInventoryId) == 1,
      "Air does not have correct number of mined objects in inventory"
    );

    // fill up inventory
    bytes32 inventoryId;
    for (uint i = 0; i < NUM_MAX_INVENTORY_SLOTS; i++) {
      inventoryId = getUniqueEntity();
      Inventory.set(inventoryId, agentObjectEntityId);
      ObjectProperties memory objectProperties;
      InventoryObject.set(inventoryId, GrassObjectID, 1, 1, abi.encode(objectProperties));
    }

    // Move into the air and pick up the item
    vm.expectRevert();
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, dropCoord);

    vm.stopPrank();
  }

  function testTransferToChest() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    bytes32 inventoryId = getUniqueEntity();
    Inventory.set(inventoryId, agentObjectEntityId);
    ObjectProperties memory objectProperties;
    InventoryObject.set(inventoryId, ChestObjectID, 1, 0, abi.encode(objectProperties));

    VoxelCoord memory chestCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z - 1);
    world.build(agentObjectEntityId, ChestObjectID, chestCoord, inventoryId);
    bytes32 chestEntityId = getEntityAtCoord(store, chestCoord);
    assertTrue(uint256(chestEntityId) != 0, "Chest not found at coord");
    bytes32 chestObjectEntityId = ObjectEntity.get(store, chestEntityId);
    assertTrue(chestObjectEntityId != bytes32(0), "Chest not found at coord");

    // Mine a block
    VoxelCoord memory mineCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
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

    bytes32[][] memory chestObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(chestObjectEntityId));
    assertTrue(chestObjects.length == 0, "Agent does not have inventory");

    // Transfer to chest
    world.transfer(agentObjectEntityId, chestCoord, agentInventoryId, 1);

    agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 0, "Agent has inventory");

    chestObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(chestObjectEntityId));
    assertTrue(chestObjects.length == 1, "Agent does not have inventory");
    assertTrue(chestObjects[0].length == 1, "Agent does not have inventory");
    {
      bytes32 chestInventoryId = chestObjects[0][0];
      bytes32 chestInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, chestInventoryId);
      assertTrue(chestInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");
      assertTrue(
        InventoryObject.getNumObjects(store, chestInventoryId) == 1,
        "Agent does not have correct number of mined objects in inventory"
      );
    }

    // Mine the chest
    world.mine(agentObjectEntityId, ChestObjectID, chestCoord);
    // Air should be at the chest coord
    chestObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(chestObjectEntityId));
    assertTrue(chestObjects.length == 1, "Agent does not have inventory");

    // Move into the chest and pick up the item
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, chestCoord);
    agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 2, "Agent does not have inventory");
    assertTrue(agentObjects[0].length == 1, "Agent does not have inventory");
    agentInventoryId = agentObjects[0][0];
    agentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, agentInventoryId);
    assertTrue(agentInventoryObjectTypeId == ChestObjectID, "Agent does not have mined object in inventory");
    assertTrue(
      InventoryObject.getNumObjects(store, agentInventoryId) == 1,
      "Agent does not have correct number of mined objects in inventory"
    );
    assertTrue(agentObjects[1].length == 1, "Agent does not have inventory");
    agentInventoryId = agentObjects[1][0];
    agentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, agentInventoryId);
    assertTrue(agentInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");
    assertTrue(
      InventoryObject.getNumObjects(store, agentInventoryId) == 1,
      "Agent does not have correct number of mined objects in inventory"
    );

    chestObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(chestObjectEntityId));
    assertTrue(chestObjects.length == 0, "Agent does not have inventory");

    vm.stopPrank();
  }

  function testTransferToFullChest() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    bytes32 inventoryId = getUniqueEntity();
    Inventory.set(inventoryId, agentObjectEntityId);
    ObjectProperties memory objectProperties;
    InventoryObject.set(inventoryId, ChestObjectID, 1, 0, abi.encode(objectProperties));

    VoxelCoord memory chestCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z - 1);
    world.build(agentObjectEntityId, ChestObjectID, chestCoord, inventoryId);
    bytes32 chestEntityId = getEntityAtCoord(store, chestCoord);
    assertTrue(uint256(chestEntityId) != 0, "Chest not found at coord");
    bytes32 chestObjectEntityId = ObjectEntity.get(store, chestEntityId);
    assertTrue(chestObjectEntityId != bytes32(0), "Chest not found at coord");

    // Mine a block
    VoxelCoord memory mineCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
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

    bytes32[][] memory chestObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(chestObjectEntityId));
    assertTrue(chestObjects.length == 0, "Agent does not have inventory");

    // fill up inventory
    for (uint i = 0; i < MAX_CHEST_SLOTS; i++) {
      inventoryId = getUniqueEntity();
      Inventory.set(inventoryId, chestObjectEntityId);
      ObjectProperties memory objectProperties;
      InventoryObject.set(inventoryId, GrassObjectID, 1, 1, abi.encode(objectProperties));
    }

    // Transfer to chest
    vm.expectRevert();
    world.transfer(agentObjectEntityId, chestCoord, agentInventoryId, 1);

    vm.stopPrank();
  }

  function testTransferFromChest() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    bytes32 inventoryId = getUniqueEntity();
    Inventory.set(inventoryId, agentObjectEntityId);
    ObjectProperties memory objectProperties;
    InventoryObject.set(inventoryId, ChestObjectID, 1, 0, abi.encode(objectProperties));

    VoxelCoord memory chestCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z - 1);
    world.build(agentObjectEntityId, ChestObjectID, chestCoord, inventoryId);
    bytes32 chestEntityId = getEntityAtCoord(store, chestCoord);
    assertTrue(uint256(chestEntityId) != 0, "Chest not found at coord");
    bytes32 chestObjectEntityId = ObjectEntity.get(store, chestEntityId);
    assertTrue(chestObjectEntityId != bytes32(0), "Chest not found at coord");

    // Mine a block
    VoxelCoord memory mineCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y - 1, initialAgentCoord.z - 1);
    bytes32 objectTypeId = world.getTerrainObjectTypeId(mineCoord);
    world.mine(agentObjectEntityId, objectTypeId, mineCoord);
    // get the inventory of the agent
    bytes32[][] memory agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 1, "Agent does not have inventory");
    assertTrue(agentObjects[0].length == 1, "Agent does not have inventory");
    bytes32 agentInventoryId = agentObjects[0][0];
    {
      bytes32 agentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, agentInventoryId);
      assertTrue(agentInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");
      assertTrue(
        InventoryObject.getNumObjects(store, agentInventoryId) == 1,
        "Agent does not have correct number of mined objects in inventory"
      );
    }

    bytes32[][] memory chestObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(chestObjectEntityId));
    assertTrue(chestObjects.length == 0, "Agent does not have inventory");

    // Transfer to chest
    world.transfer(agentObjectEntityId, chestCoord, agentInventoryId, 1);

    agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 0, "Agent has inventory");

    chestObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(chestObjectEntityId));
    assertTrue(chestObjects.length == 1, "Agent does not have inventory");
    assertTrue(chestObjects[0].length == 1, "Agent does not have inventory");
    bytes32 chestInventoryId = chestObjects[0][0];
    {
      bytes32 chestInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, chestInventoryId);
      assertTrue(chestInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");
      assertTrue(
        InventoryObject.getNumObjects(store, chestInventoryId) == 1,
        "Agent does not have correct number of mined objects in inventory"
      );
    }

    // move agent away
    VoxelCoord memory newAgentCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y, initialAgentCoord.z + 1);
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, newAgentCoord);

    // Try taking from chest, should be too far
    vm.expectRevert();
    world.transfer(chestObjectEntityId, newAgentCoord, chestInventoryId, 1);

    vm.stopPrank();

    vm.startPrank(bob, bob);
    (, bytes32 bobAgentObjectEntityId) = setupAgent();

    bytes32[][] memory bobAgentObjects = getKeysWithValue(
      store,
      InventoryTableId,
      Inventory.encode(bobAgentObjectEntityId)
    );
    assertTrue(bobAgentObjects.length == 0, "Agent has inventory");

    // Transfer from chest
    world.transfer(chestObjectEntityId, initialAgentCoord, chestInventoryId, 1);

    bobAgentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(bobAgentObjectEntityId));
    assertTrue(bobAgentObjects.length == 1, "Agent does not have inventory");
    assertTrue(bobAgentObjects[0].length == 1, "Agent does not have inventory");
    bytes32 bobAgentInventoryId = bobAgentObjects[0][0];
    bytes32 bobAgentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, bobAgentInventoryId);
    assertTrue(bobAgentInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");
    assertTrue(
      InventoryObject.getNumObjects(store, bobAgentInventoryId) == 1,
      "Agent does not have correct number of mined objects in inventory"
    );

    chestObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(chestObjectEntityId));
    assertTrue(chestObjects.length == 0, "Agent does not have inventory");

    vm.stopPrank();
  }
}
