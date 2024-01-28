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

  function testSimpleMoveOnGround() public {
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
}
