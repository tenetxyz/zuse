// SPDX-License-Identifier: GPL-3.0
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
import { SIMULATOR_ADDRESS, BuilderObjectID, DirtObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";
import { WORLD_ADDRESS, REGISTRY_ADDRESS, NUM_BLOCKS_FAINTED, ThermoObjectID, FireCreatureObjectID, WaterCreatureObjectID, GrassCreatureObjectID } from "@tenet-creatures/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Health, HealthData } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Temperature } from "@tenet-simulator/src/codegen/tables/Temperature.sol";
import { Element } from "@tenet-simulator/src/codegen/tables/Element.sol";

import { Thermo, ThermoData } from "@tenet-creatures/src/codegen/tables/Thermo.sol";

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

contract ThermoTest is MudTest {
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

  function testThermoWithThermoNeighbour() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    // Note: this coordinate has to be diagonal to the agent
    // otherwise the agent will lose health
    VoxelCoord memory thermoCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z + 1 });
    bytes32 thermoEntityId = world.build(agentObjectEntityId, ThermoObjectID, thermoCoord);
    bytes32 thermoObjectEntityId = ObjectEntity.get(store, thermoEntityId);
    Energy.set(simStore, worldAddress, thermoObjectEntityId, 500);

    vm.roll(block.number + 1);
    world.activate(agentObjectEntityId, ThermoObjectID, thermoCoord);
    assertTrue(Temperature.get(simStore, worldAddress, thermoObjectEntityId) > 0, "Temperature not > 0");
    assertTrue(Energy.get(simStore, worldAddress, thermoObjectEntityId) == 0, "Energy not 0");

    // Place down another thermo beside it
    VoxelCoord memory thermoCoord2 = VoxelCoord({ x: thermoCoord.x, y: thermoCoord.y + 1, z: thermoCoord.z });
    vm.roll(block.number + 1);
    bytes32 thermo2EntityId = world.build(agentObjectEntityId, ThermoObjectID, thermoCoord2);
    bytes32 thermo2ObjectEntityId = ObjectEntity.get(store, thermo2EntityId);
    assertTrue(Energy.get(simStore, worldAddress, thermo2ObjectEntityId) == 0, "Energy not 0");
    assertTrue(Temperature.get(simStore, worldAddress, thermo2ObjectEntityId) > 0, "Temperature not > 0");

    vm.stopPrank();
  }

  function testThermoWithTwoThermoNeighbours() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    // Note: this coordinate has to be diagonal to the agent
    // otherwise the agent will lose health
    VoxelCoord memory thermoCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z + 1 });
    bytes32 thermoEntityId = world.build(agentObjectEntityId, ThermoObjectID, thermoCoord);
    bytes32 thermoObjectEntityId = ObjectEntity.get(store, thermoEntityId);
    Energy.set(simStore, worldAddress, thermoObjectEntityId, 500);

    vm.roll(block.number + 1);
    world.activate(agentObjectEntityId, ThermoObjectID, thermoCoord);
    assertTrue(Temperature.get(simStore, worldAddress, thermoObjectEntityId) > 0, "Temperature not > 0");
    assertTrue(Energy.get(simStore, worldAddress, thermoObjectEntityId) == 0, "Energy not 0");

    // Place down another thermo beside it
    VoxelCoord memory thermoCoord2 = VoxelCoord({ x: thermoCoord.x, y: thermoCoord.y + 1, z: thermoCoord.z });
    vm.roll(block.number + 1);
    bytes32 thermo2EntityId = world.build(agentObjectEntityId, ThermoObjectID, thermoCoord2);
    bytes32 thermo2ObjectEntityId = ObjectEntity.get(store, thermo2EntityId);
    assertTrue(Energy.get(simStore, worldAddress, thermo2ObjectEntityId) == 0, "Energy not 0");
    assertTrue(Temperature.get(simStore, worldAddress, thermo2ObjectEntityId) > 0, "Temperature not > 0");

    // Place down another thermo beside it
    VoxelCoord memory thermoCoord3 = VoxelCoord({ x: thermoCoord2.x, y: thermoCoord2.y, z: thermoCoord2.z - 1 });
    vm.roll(block.number + 1);
    bytes32 thermo3EntityId = world.build(agentObjectEntityId, ThermoObjectID, thermoCoord3);
    bytes32 thermo3ObjectEntityId = ObjectEntity.get(store, thermo3EntityId);
    assertTrue(Energy.get(simStore, worldAddress, thermo3ObjectEntityId) == 0, "Energy not 0");
    assertTrue(Temperature.get(simStore, worldAddress, thermo3ObjectEntityId) > 0, "Temperature not > 0");

    vm.stopPrank();
  }

  function testThermoWithNonFireAgent() public {
    vm.startPrank(alice, alice);
    // Setup agent by default uses a non-fire agent
    (, bytes32 agentObjectEntityId) = setupAgent();

    HealthData memory initialHealth = Health.get(simStore, worldAddress, agentObjectEntityId);
    assertTrue(initialHealth.health > 0, "Health not > 0");
    assertTrue(initialHealth.lastUpdateBlock == 0, "lastUpdateBlock not 0");

    VoxelCoord memory thermoCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    bytes32 thermoEntityId = world.build(agentObjectEntityId, ThermoObjectID, thermoCoord);
    bytes32 thermoObjectEntityId = ObjectEntity.get(store, thermoEntityId);
    uint256 difference = 10;
    uint256 initialEnergy = initialHealth.health + difference;
    Energy.set(simStore, worldAddress, thermoObjectEntityId, initialEnergy);

    vm.roll(block.number + 1);
    world.activate(agentObjectEntityId, ThermoObjectID, thermoCoord);
    assertTrue(
      Temperature.get(simStore, worldAddress, thermoObjectEntityId) == initialEnergy - difference, // ie lost difference
      "Temperature not > 0"
    );
    assertTrue(Energy.get(simStore, worldAddress, thermoObjectEntityId) == 0, "Energy not 0");

    HealthData memory newHealth = Health.get(simStore, worldAddress, agentObjectEntityId);
    // health should have decreased
    assertTrue(newHealth.health == initialHealth.health - difference, "Health not < initialHealth.health");
    assertTrue(newHealth.lastUpdateBlock == block.number, "lastUpdateBlock not block.number");

    vm.stopPrank();
  }

  function testThermoWithFireAgent() public {
    vm.startPrank(alice, alice);

    bytes32 agentObjectEntityId;
    {
      bytes32 faucetEntityId = getEntityAtCoord(store, faucetAgentCoord);
      assertTrue(uint256(faucetEntityId) != 0, "Agent not found at coord");
      bytes32 faucetObjectEntityId = ObjectEntity.get(store, faucetEntityId);

      // Fire crearture has element type fire
      bytes32 agentObjectTypeId = FireCreatureObjectID;
      bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, agentObjectTypeId, agentCoord);
      assertTrue(uint256(agentEntityId) != 0, "Agent not found at coord");
      agentObjectEntityId = ObjectEntity.get(store, agentEntityId);
    }
    Health.setHealth(simStore, worldAddress, agentObjectEntityId, 500);

    HealthData memory initialHealth = Health.get(simStore, worldAddress, agentObjectEntityId);
    assertTrue(initialHealth.health > 0, "Health not > 0");
    assertTrue(initialHealth.lastUpdateBlock == 0, "lastUpdateBlock not 0");

    VoxelCoord memory thermoCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    bytes32 thermoEntityId = world.build(agentObjectEntityId, ThermoObjectID, thermoCoord);
    bytes32 thermoObjectEntityId = ObjectEntity.get(store, thermoEntityId);
    uint256 difference = 10;
    uint256 initialEnergy = initialHealth.health + difference;
    Energy.set(simStore, worldAddress, thermoObjectEntityId, initialEnergy);

    vm.roll(block.number + 1);
    world.activate(agentObjectEntityId, ThermoObjectID, thermoCoord);
    assertTrue(
      Temperature.get(simStore, worldAddress, thermoObjectEntityId) == initialEnergy - difference, // ie lost difference
      "Temperature not > 0"
    );
    assertTrue(Energy.get(simStore, worldAddress, thermoObjectEntityId) == 0, "Energy not 0");

    HealthData memory newHealth = Health.get(simStore, worldAddress, agentObjectEntityId);
    // health should have increased
    assertTrue(newHealth.health == initialHealth.health + difference, "Health not > initialHealth.health");
    assertTrue(newHealth.lastUpdateBlock == block.number, "lastUpdateBlock not block.number");

    vm.stopPrank();
  }

  function testThermoLaunch() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    // Note: this coordinate has to be diagonal to the agent
    // otherwise the agent will lose health
    VoxelCoord memory thermoCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z + 1 });
    bytes32 thermoEntityId = world.build(agentObjectEntityId, ThermoObjectID, thermoCoord);
    bytes32 thermoObjectEntityId = ObjectEntity.get(store, thermoEntityId);
    Energy.set(simStore, worldAddress, thermoObjectEntityId, 500);

    vm.roll(block.number + 1);
    world.activate(agentObjectEntityId, ThermoObjectID, thermoCoord);
    uint256 temperature = Temperature.get(simStore, worldAddress, thermoObjectEntityId);
    assertTrue(temperature > 0, "Temperature not > 0");
    assertTrue(Energy.get(simStore, worldAddress, thermoObjectEntityId) == 0, "Energy not 0");

    // Place down another thermo beside it
    VoxelCoord memory dirtCoord = VoxelCoord({ x: thermoCoord.x, y: thermoCoord.y + 1, z: thermoCoord.z });
    vm.roll(block.number + 1);
    bytes32 dirtEntityId = world.build(agentObjectEntityId, DirtObjectID, dirtCoord);
    // Since the dirt object would have moved, we need to get the correct one at the final coord
    dirtEntityId = getEntityAtCoord(store, VoxelCoord(dirtCoord.x, dirtCoord.y, dirtCoord.z + 4));

    bytes32 dirtObjectEntityId = ObjectEntity.get(store, dirtEntityId);
    assertTrue(ObjectType.get(store, dirtEntityId) == DirtObjectID, "Dirt not found");
    VoxelCoord memory dirtVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, dirtObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(dirtVelocity.x == 0 && dirtVelocity.y == 0 && dirtVelocity.z == 4, "Dirt velocity not 0,0,4");
    assertTrue(
      Temperature.get(simStore, worldAddress, thermoObjectEntityId) < temperature,
      "Temperature not < temperature"
    );

    vm.stopPrank();
  }
}
