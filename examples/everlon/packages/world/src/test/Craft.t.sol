// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { ObjectType, OwnedBy, ObjectEntity, Recipes, RecipesData, RecipesTableId, Equipped } from "@tenet-world/src/codegen/Tables.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { BuilderObjectID, RunnerObjectID, GrassObjectID, OakLogObjectID, OakLumberObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

contract CraftTest is MudTest {
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

    initialAgentCoord = VoxelCoord(faucetAgentCoord.x, faucetAgentCoord.y, faucetAgentCoord.z + 1);
    bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, agentObjectTypeId, initialAgentCoord);
    assertTrue(uint256(agentEntityId) != 0, "Agent not found at coord");
    bytes32 agentObjectEntityId = ObjectEntity.get(store, agentEntityId);

    return (agentEntityId, agentObjectEntityId);
  }

  function testSingleInputMultipleOutputCraft() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory mineCoord = VoxelCoord(198, 27, 208); // hard coded to oak log
    bytes32 objectTypeId = world.getTerrainObjectTypeId(mineCoord);
    assertTrue(objectTypeId == OakLogObjectID, "Terrain object is not oak log");
    world.mine(agentObjectEntityId, objectTypeId, mineCoord);
    // get the inventory of the agent
    bytes32[][] memory agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 1, "Agent does not have inventory");
    assertTrue(agentObjects[0].length == 1, "Agent does not have inventory");
    bytes32 agentInventoryId = agentObjects[0][0];
    bytes32 agentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, agentInventoryId);
    assertTrue(agentInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");

    bytes32[][] memory allRecipes = getKeysInTable(store, RecipesTableId);
    // First recipe is for oak
    assertTrue(
      Recipes.get(allRecipes[0][0]).inputObjectTypeIds[0] == OakLogObjectID,
      "First recipe is not for oak log"
    );
    bytes32[] memory ingredientIds = new bytes32[](1);
    ingredientIds[0] = agentInventoryId;
    world.craft(agentObjectEntityId, allRecipes[0][0], ingredientIds);

    // Assert that the inventory has the crafted item
    agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 4, "Agent does not have inventory");
    for (uint i = 0; i < agentObjects.length; i++) {
      agentInventoryId = agentObjects[i][0];
      agentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, agentInventoryId);
      assertTrue(agentInventoryObjectTypeId == OakLumberObjectID, "Agent does not have crafted object in inventory");
    }

    // Try crafting again
    vm.expectRevert();
    world.craft(agentObjectEntityId, allRecipes[0][0], ingredientIds);

    vm.stopPrank();
  }

  function testInvalidRecipe() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    bytes32[] memory ingredientIds = new bytes32[](1);

    vm.expectRevert();
    world.craft(agentObjectEntityId, bytes32(uint256(300000)), ingredientIds);

    vm.stopPrank();
  }

  function testEquip() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory mineCoord = VoxelCoord(198, 27, 208); // hard coded to oak log
    bytes32 objectTypeId = world.getTerrainObjectTypeId(mineCoord);
    assertTrue(objectTypeId == OakLogObjectID, "Terrain object is not oak log");
    world.mine(agentObjectEntityId, objectTypeId, mineCoord);
    // get the inventory of the agent
    bytes32[][] memory agentObjects = getKeysWithValue(store, InventoryTableId, Inventory.encode(agentObjectEntityId));
    assertTrue(agentObjects.length == 1, "Agent does not have inventory");
    assertTrue(agentObjects[0].length == 1, "Agent does not have inventory");
    bytes32 agentInventoryId = agentObjects[0][0];
    bytes32 agentInventoryObjectTypeId = InventoryObject.getObjectTypeId(store, agentInventoryId);
    assertTrue(agentInventoryObjectTypeId == objectTypeId, "Agent does not have mined object in inventory");

    world.equip(agentObjectEntityId, agentInventoryId);
    assertTrue(
      Equipped.get(store, agentObjectEntityId) == agentInventoryId,
      "Agent is not equipped with the inventory"
    );

    world.build(
      agentObjectEntityId,
      objectTypeId,
      VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z + 1),
      agentInventoryId
    );
    assertTrue(
      Equipped.get(store, agentObjectEntityId) == bytes32(uint256(0)),
      "Agent is still equipped with the inventory"
    );

    vm.expectRevert();
    world.equip(agentObjectEntityId, agentInventoryId);

    vm.stopPrank();
  }
}
