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

contract AgentTest is MudTest {
  IWorld private world;
  IStore private store;
  IStore private simStore;
  address payable internal alice;
  VoxelCoord faucetAgentCoord = VoxelCoord(197, 27, 203);

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    simStore = IStore(SIMULATOR_ADDRESS);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
  }

  function testFaucetAgent() public {
    vm.startPrank(alice, alice);

    bytes32 faucetEntityId = getEntityAtCoord(store, faucetAgentCoord);
    assertTrue(uint256(faucetEntityId) != 0, "Agent not found at coord");
    bytes32 faucetObjectEntityId = ObjectEntity.get(store, faucetEntityId);
    assertTrue(Health.getHealth(simStore, worldAddress, faucetObjectEntityId) > 0, "Faucet does not have health");
    assertTrue(Stamina.get(simStore, worldAddress, faucetObjectEntityId) > 0, "Faucet does not have stamina");

    VoxelCoord memory initialAgentCoord = VoxelCoord(faucetAgentCoord.x, faucetAgentCoord.y, faucetAgentCoord.z - 1);
    bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, BuilderObjectID, initialAgentCoord);
    assertTrue(uint256(agentEntityId) != 0, "Agent not found at coord");
    bytes32 agentObjectEntityId = ObjectEntity.get(store, agentEntityId);
    assertTrue(Health.getHealth(simStore, worldAddress, agentObjectEntityId) > 0, "Faucet did not transfer health");
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) > 0, "Faucet did not transfer stamina");

    vm.stopPrank();
  }

  function testFaucetAgentInvalid() public {
    vm.startPrank(alice, alice);

    bytes32 faucetEntityId = getEntityAtCoord(store, faucetAgentCoord);
    assertTrue(uint256(faucetEntityId) != 0, "Agent not found at coord");
    bytes32 faucetObjectEntityId = ObjectEntity.get(store, faucetEntityId);
    assertTrue(Health.getHealth(simStore, worldAddress, faucetObjectEntityId) > 0, "Faucet does not have health");
    assertTrue(Stamina.get(simStore, worldAddress, faucetObjectEntityId) > 0, "Faucet does not have stamina");

    // You can only build one coord away from the faucet
    VoxelCoord memory initialAgentCoord = VoxelCoord(faucetAgentCoord.x, faucetAgentCoord.y, faucetAgentCoord.z + 2);
    vm.expectRevert();
    world.claimAgentFromFaucet(faucetObjectEntityId, BuilderObjectID, initialAgentCoord);

    vm.stopPrank();
  }

  function testBuilderAgent() public {
    vm.startPrank(alice, alice);

    bytes32 faucetEntityId = getEntityAtCoord(store, faucetAgentCoord);
    assertTrue(uint256(faucetEntityId) != 0, "Agent not found at coord");
    bytes32 faucetObjectEntityId = ObjectEntity.get(store, faucetEntityId);

    VoxelCoord memory initialAgentCoord = VoxelCoord(faucetAgentCoord.x, faucetAgentCoord.y, faucetAgentCoord.z - 1);
    bytes32 agentObjectTypeId = BuilderObjectID;
    bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, agentObjectTypeId, initialAgentCoord);
    assertTrue(uint256(agentEntityId) != 0, "Agent not found at coord");
    bytes32 agentObjectEntityId = ObjectEntity.get(store, agentEntityId);

    VoxelCoord memory newCoord = VoxelCoord(initialAgentCoord.x, initialAgentCoord.y, initialAgentCoord.z - 1);
    VoxelCoord memory initialVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(
      initialVelocity.x == 0 && initialVelocity.y == 0 && initialVelocity.z == 0,
      "Agent has initial velocity"
    );
    world.move(agentObjectEntityId, agentObjectTypeId, initialAgentCoord, newCoord);
    VoxelCoord memory finalVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(finalVelocity.x == 0 && finalVelocity.y == 0 && finalVelocity.z == 0, "Agent has final velocity");

    vm.stopPrank();
  }
}
