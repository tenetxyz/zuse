// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";
import { IFaucetSystem } from "@tenet-world/src/codegen/world/IFaucetSystem.sol";
import { IMoveSystem } from "@tenet-world/src/codegen/world/IMoveSystem.sol";
import { IBuildSystem } from "@tenet-world/src/codegen/world/IBuildSystem.sol";
import { IMineSystem } from "@tenet-world/src/codegen/world/IMineSystem.sol";
import { IActivateSystem } from "@tenet-world/src/codegen/world/IActivateSystem.sol";
import { IAgentSystem } from "@tenet-world/src/codegen/world/IAgentSystem.sol";
import { IMindSystem } from "@tenet-world/src/codegen/world/IMindSystem.sol";

import { MindRegistry } from "@tenet-registry/src/codegen/tables/MindRegistry.sol";

import { ObjectType } from "@tenet-world/src/codegen/tables/ObjectType.sol";
import { OwnedBy } from "@tenet-world/src/codegen/tables/OwnedBy.sol";
import { ObjectEntity } from "@tenet-world/src/codegen/tables/ObjectEntity.sol";
import { VoxelCoord, ElementType, Mind } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { SIMULATOR_ADDRESS, BuilderObjectID, GrassObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";
import { WORLD_ADDRESS, REGISTRY_ADDRESS, NUM_BLOCKS_FAINTED, FireCreatureObjectID, WaterCreatureObjectID, GrassCreatureObjectID } from "@tenet-creatures/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Element } from "@tenet-simulator/src/codegen/tables/Element.sol";

import { Creature, CreatureData } from "@tenet-creatures/src/codegen/tables/Creature.sol";

// TODO: Replace relative imports in IWorld.sol, instead of this hack
interface IWorld is
  IBaseWorld,
  IBuildSystem,
  IMineSystem,
  IMoveSystem,
  IActivateSystem,
  IFaucetSystem,
  IAgentSystem,
  IMindSystem
{

}

contract CreatureTest is MudTest {
  IWorld private world;
  IStore private store;
  IStore private simStore;
  address payable internal alice;
  VoxelCoord faucetAgentCoord = VoxelCoord(50, 10, 50);
  VoxelCoord agentCoord;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    simStore = IStore(SIMULATOR_ADDRESS);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    agentCoord = VoxelCoord({ x: faucetAgentCoord.x + 1, y: faucetAgentCoord.y, z: faucetAgentCoord.z });
  }

  function setupAgent() internal returns (bytes32, bytes32) {
    bytes32 faucetEntityId = getEntityAtCoord(store, faucetAgentCoord);
    assertTrue(uint256(faucetEntityId) != 0, "Agent not found at coord");
    bytes32 faucetObjectEntityId = ObjectEntity.get(store, faucetEntityId);

    bytes32 agentObjectTypeId = BuilderObjectID;
    bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, agentObjectTypeId, agentCoord);
    assertTrue(uint256(agentEntityId) != 0, "Agent not found at coord");
    bytes32 agentObjectEntityId = ObjectEntity.get(store, agentEntityId);

    return (agentEntityId, agentObjectEntityId);
  }

  function testFightSameCreatures() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    address fireMindAddress;
    bytes4 fireMindSelector;
    {
      bytes memory mindData = MindRegistry.get(IStore(REGISTRY_ADDRESS), FireCreatureObjectID);
      Mind[] memory minds = abi.decode(mindData, (Mind[]));
      assertTrue(minds.length == 1, "Fire test mind not found");
      fireMindAddress = minds[0].mindAddress;
      fireMindSelector = minds[0].mindSelector;
    }

    VoxelCoord memory creature1Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z + 1 });
    bytes32 creature1EntityId = world.build(agentObjectEntityId, FireCreatureObjectID, creature1Coord);
    world.claimAgent(creature1EntityId);
    bytes32 creature1ObjectEntityId = ObjectEntity.get(store, creature1EntityId);
    assertTrue(Element.get(simStore, worldAddress, creature1ObjectEntityId) == ElementType.Fire, "Element not found");

    // Prep for fight
    Health.setHealth(simStore, worldAddress, creature1ObjectEntityId, 100);
    Stamina.set(simStore, worldAddress, creature1ObjectEntityId, 50000);
    world.setMindSelector(creature1ObjectEntityId, fireMindAddress, fireMindSelector);

    VoxelCoord memory creature2Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z - 1 });
    bytes32 creature2EntityId = world.build(agentObjectEntityId, FireCreatureObjectID, creature2Coord);
    world.claimAgent(creature2EntityId);
    bytes32 creature2ObjectEntityId = ObjectEntity.get(store, creature2EntityId);
    assertTrue(Element.get(simStore, worldAddress, creature2ObjectEntityId) == ElementType.Fire, "Element not found");

    // Prep for fight
    Health.setHealth(simStore, worldAddress, creature2ObjectEntityId, 100);
    Stamina.set(simStore, worldAddress, creature2ObjectEntityId, 50000);
    world.setMindSelector(creature2ObjectEntityId, fireMindAddress, fireMindSelector);

    // Move creatures beside each other, so they fight!
    VoxelCoord memory newCreature1Coord = VoxelCoord({
      x: creature1Coord.x,
      y: creature1Coord.y,
      z: creature1Coord.z - 1
    });
    vm.roll(block.number + 1);

    world.move(agentObjectEntityId, FireCreatureObjectID, creature1Coord, newCreature1Coord);

    // Check both creatures are fainted, so tied
    assertTrue(Health.getHealth(simStore, worldAddress, creature1ObjectEntityId) == 0, "Creature 1 health not 0");
    assertTrue(Health.getHealth(simStore, worldAddress, creature2ObjectEntityId) == 0, "Creature 2 health not 0");
    CreatureData memory creature1Data = Creature.get(store, worldAddress, creature1ObjectEntityId);
    assertTrue(creature1Data.elementType == ElementType.Fire, "Creature 1 element not Fire");
    assertTrue(creature1Data.fightingObjectEntityId == bytes32(0), "Creature 1 fighting entity not 0");
    assertTrue(creature1Data.isFainted == true, "Creature 1 not fainted");
    assertTrue(creature1Data.lastFaintedBlock > 0, "Creature 1 last fainted block not > 0");
    assertTrue(creature1Data.numWins == 0, "Creature 1 num wins not 0");
    assertTrue(creature1Data.numLosses == 0, "Creature 1 num losses not 0");

    CreatureData memory creature2Data = Creature.get(store, worldAddress, creature2ObjectEntityId);
    assertTrue(creature2Data.elementType == ElementType.Fire, "Creature 2 element not Fire");
    assertTrue(creature2Data.fightingObjectEntityId == bytes32(0), "Creature 2 fighting entity not 0");
    assertTrue(creature2Data.isFainted == true, "Creature 2 not fainted");
    assertTrue(creature2Data.lastFaintedBlock > 0, "Creature 2 last fainted block not > 0");
    assertTrue(creature2Data.numWins == 0, "Creature 2 num wins not 0");
    assertTrue(creature2Data.numLosses == 0, "Creature 2 num losses not 0");

    // Roll forward NUM_BLOCKS_FAINTED and assert that they can now fight again
    vm.roll(block.number + NUM_BLOCKS_FAINTED + 1);
    world.activate(agentObjectEntityId, FireCreatureObjectID, newCreature1Coord);
    creature1Data = Creature.get(store, worldAddress, creature1ObjectEntityId);
    assertTrue(creature1Data.isFainted == false, "Creature 1 still fainted");
    creature2Data = Creature.get(store, worldAddress, creature2ObjectEntityId);
    assertTrue(creature2Data.isFainted == false, "Creature 2 still fainted");

    vm.stopPrank();
  }

  function testFightDiffCreatures() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    address fireMindAddress;
    bytes4 fireMindSelector;
    {
      bytes memory mindData = MindRegistry.get(IStore(REGISTRY_ADDRESS), FireCreatureObjectID);
      Mind[] memory minds = abi.decode(mindData, (Mind[]));
      assertTrue(minds.length == 1, "Fire test mind not found");
      fireMindAddress = minds[0].mindAddress;
      fireMindSelector = minds[0].mindSelector;
    }

    address grassMindAddress;
    bytes4 grassMindSelector;
    {
      bytes memory mindData = MindRegistry.get(IStore(REGISTRY_ADDRESS), GrassCreatureObjectID);
      Mind[] memory minds = abi.decode(mindData, (Mind[]));
      assertTrue(minds.length == 1, "Grass test mind not found");
      grassMindAddress = minds[0].mindAddress;
      grassMindSelector = minds[0].mindSelector;
    }

    VoxelCoord memory creature1Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z + 1 });
    bytes32 creature1EntityId = world.build(agentObjectEntityId, FireCreatureObjectID, creature1Coord);
    world.claimAgent(creature1EntityId);
    bytes32 creature1ObjectEntityId = ObjectEntity.get(store, creature1EntityId);
    assertTrue(Element.get(simStore, worldAddress, creature1ObjectEntityId) == ElementType.Fire, "Element not found");

    // Prep for fight
    Health.setHealth(simStore, worldAddress, creature1ObjectEntityId, 100);
    Stamina.set(simStore, worldAddress, creature1ObjectEntityId, 50000);
    world.setMindSelector(creature1ObjectEntityId, fireMindAddress, fireMindSelector);

    VoxelCoord memory creature2Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z - 1 });
    bytes32 creature2EntityId = world.build(agentObjectEntityId, GrassCreatureObjectID, creature2Coord);
    world.claimAgent(creature2EntityId);
    bytes32 creature2ObjectEntityId = ObjectEntity.get(store, creature2EntityId);
    assertTrue(Element.get(simStore, worldAddress, creature2ObjectEntityId) == ElementType.Grass, "Element not found");

    // Prep for fight
    Health.setHealth(simStore, worldAddress, creature2ObjectEntityId, 100);
    Stamina.set(simStore, worldAddress, creature2ObjectEntityId, 50000);
    world.setMindSelector(creature2ObjectEntityId, grassMindAddress, grassMindSelector);

    // Move creatures beside each other, so they fight!
    VoxelCoord memory newCreature1Coord = VoxelCoord({
      x: creature1Coord.x,
      y: creature1Coord.y,
      z: creature1Coord.z - 1
    });
    vm.roll(block.number + 1);

    world.move(agentObjectEntityId, FireCreatureObjectID, creature1Coord, newCreature1Coord);

    // Check grass creature fainted, as it only did defensive moves
    assertTrue(Health.getHealth(simStore, worldAddress, creature1ObjectEntityId) == 100, "Creature 1 health not full");
    assertTrue(Health.getHealth(simStore, worldAddress, creature2ObjectEntityId) == 0, "Creature 2 health not 0");
    CreatureData memory creature1Data = Creature.get(store, worldAddress, creature1ObjectEntityId);
    assertTrue(creature1Data.elementType == ElementType.Fire, "Creature 1 element not Fire");
    assertTrue(creature1Data.fightingObjectEntityId == bytes32(0), "Creature 1 fighting entity not 0");
    assertTrue(creature1Data.isFainted == false, "Creature 1 not fainted");
    assertTrue(creature1Data.numWins == 1, "Creature 1 num wins not 0");
    assertTrue(creature1Data.numLosses == 0, "Creature 1 num losses not 0");

    CreatureData memory creature2Data = Creature.get(store, worldAddress, creature2ObjectEntityId);
    assertTrue(creature2Data.elementType == ElementType.Grass, "Creature 2 element not Fire");
    assertTrue(creature2Data.fightingObjectEntityId == bytes32(0), "Creature 2 fighting entity not 0");
    assertTrue(creature2Data.isFainted == true, "Creature 2 not fainted");
    assertTrue(creature2Data.lastFaintedBlock > 0, "Creature 2 last fainted block not > 0");
    assertTrue(creature2Data.numWins == 0, "Creature 2 num wins not 0");
    assertTrue(creature2Data.numLosses == 1, "Creature 2 num losses not 0");

    // Roll forward NUM_BLOCKS_FAINTED and assert that they can now fight again
    vm.roll(block.number + NUM_BLOCKS_FAINTED + 1);
    world.activate(agentObjectEntityId, GrassCreatureObjectID, creature2Coord);
    creature2Data = Creature.get(store, worldAddress, creature2ObjectEntityId);
    assertTrue(creature2Data.isFainted == false, "Creature 2 still fainted");

    vm.stopPrank();
  }
}
