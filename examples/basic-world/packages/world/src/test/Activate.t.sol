// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ObjectType, OwnedBy, ObjectEntity } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { BuilderObjectID, GrassObjectID, AirObjectID, BedrockObjectID } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";

contract ActivateTest is MudTest {
  IWorld private world;
  IStore private store;
  address payable internal alice;
  VoxelCoord initialAgentCoord = VoxelCoord(50, 10, 50);

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
  }

  function testActivateSelf() public {
    vm.startPrank(alice, alice);

    bytes32 initialAgentEntityId = getEntityAtCoord(store, initialAgentCoord);
    assertTrue(uint256(initialAgentEntityId) != 0, "Agent not found at coord");

    world.claimAgent(initialAgentEntityId);
    bytes32 agentObjectEntityId = ObjectEntity.get(store, initialAgentEntityId);
    bytes32 agentObjectTypeId = ObjectType.get(store, initialAgentEntityId);

    world.activate(agentObjectEntityId, agentObjectTypeId, initialAgentCoord);

    vm.stopPrank();
  }

  function testActivateTerrainObject() public {
    vm.startPrank(alice, alice);

    bytes32 initialAgentEntityId = getEntityAtCoord(store, initialAgentCoord);
    assertTrue(uint256(initialAgentEntityId) != 0, "Agent not found at coord");

    world.claimAgent(initialAgentEntityId);
    bytes32 agentObjectEntityId = ObjectEntity.get(store, initialAgentEntityId);

    VoxelCoord memory activateCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y - 1, initialAgentCoord.z);
    bytes32 terraninObjectTypeId = world.getTerrainObjectTypeId(activateCoord);
    assertTrue(terraninObjectTypeId == GrassObjectID, "Terrain object type not grass");
    world.activate(agentObjectEntityId, terraninObjectTypeId, activateCoord);
    assertTrue(
      ObjectType.get(store, getEntityAtCoord(store, activateCoord)) == terraninObjectTypeId,
      "Terrain object not activated"
    );

    vm.stopPrank();
  }

  function testActivateObject() public {
    vm.startPrank(alice, alice);

    bytes32 initialAgentEntityId = getEntityAtCoord(store, initialAgentCoord);
    assertTrue(uint256(initialAgentEntityId) != 0, "Agent not found at coord");

    world.claimAgent(initialAgentEntityId);
    bytes32 agentObjectEntityId = ObjectEntity.get(store, initialAgentEntityId);

    VoxelCoord memory buildCoord = VoxelCoord(initialAgentCoord.x + 1, initialAgentCoord.y, initialAgentCoord.z);
    bytes32 terraninObjectTypeId = world.getTerrainObjectTypeId(buildCoord);
    assertTrue(terraninObjectTypeId == AirObjectID, "Terrain object type not air");
    world.build(agentObjectEntityId, BedrockObjectID, buildCoord);
    assertTrue(ObjectType.get(store, getEntityAtCoord(store, buildCoord)) == BedrockObjectID, "Object not built");

    world.activate(agentObjectEntityId, BedrockObjectID, buildCoord);
    assertTrue(ObjectType.get(store, getEntityAtCoord(store, buildCoord)) == BedrockObjectID, "Object not activated");

    vm.stopPrank();
  }

  function testActivateObjectTooFar() public {
    vm.startPrank(alice, alice);

    bytes32 initialAgentEntityId = getEntityAtCoord(store, initialAgentCoord);
    assertTrue(uint256(initialAgentEntityId) != 0, "Agent not found at coord");

    world.claimAgent(initialAgentEntityId);
    bytes32 agentObjectEntityId = ObjectEntity.get(store, initialAgentEntityId);

    VoxelCoord memory activateCoord = VoxelCoord(initialAgentCoord.x + 2, initialAgentCoord.y - 1, initialAgentCoord.z);
    bytes32 terraninObjectTypeId = world.getTerrainObjectTypeId(activateCoord);
    assertTrue(terraninObjectTypeId == GrassObjectID, "Terrain object type not grass");

    vm.expectRevert();
    world.mine(agentObjectEntityId, terraninObjectTypeId, activateCoord);

    vm.stopPrank();
  }
}
