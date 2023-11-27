// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelType, OwnedBy } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, Mind } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { FaucetVoxelID, GrassVoxelID, AirVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { MindRegistry } from "@tenet-registry/src/codegen/tables/MindRegistry.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { FirePokemonVoxelID, ThermoVoxelID, ConcentrativeSoilVoxelID, ProteinSoilVoxelID, ElixirSoilVoxelID, PlantVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Thermo, ThermoData } from "@tenet-pokemon-extension/src/codegen/tables/Thermo.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Nutrients } from "@tenet-simulator/src/codegen/tables/Nutrients.sol";
import { Nitrogen } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorous } from "@tenet-simulator/src/codegen/tables/Phosphorous.sol";
import { Health, HealthData } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Potassium } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { Protein } from "@tenet-simulator/src/codegen/tables/Protein.sol";
import { Elixir } from "@tenet-simulator/src/codegen/tables/Elixir.sol";
import { Temperature } from "@tenet-simulator/src/codegen/tables/Temperature.sol";

uint256 constant INITIAL_HIGH_ENERGY = 500;

contract ThermoTest is MudTest {
  IWorld private world;
  IStore private store;
  VoxelCoord private agentCoord;

  address payable internal alice;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    agentCoord = VoxelCoord({ x: 51, y: 10, z: 50 });
  }

  function setupAgent() internal returns (VoxelEntity memory) {
    // Claim agent
    VoxelEntity memory faucetEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord({ x: 50, y: 10, z: 50 }))
    });
    VoxelEntity memory agentEntity = world.claimAgentFromFaucet(faucetEntity, FaucetVoxelID, agentCoord);
    Health.setHealth(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId, 500);
    return agentEntity;
  }

  function testThermoWithValidThermoNeighbour() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory thermoCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory thermoEntity = world.buildWithAgent(ThermoVoxelID, thermoCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId, INITIAL_HIGH_ENERGY);
    world.activateWithAgent(ThermoVoxelID, thermoCoord, agentEntity, bytes4(0));
    uint256 temperature = Temperature.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      thermoEntity.scale,
      thermoEntity.entityId
    );
    console.log("temperature");
    console.logUint(temperature);
    assertTrue(temperature > 0);
    assertTrue(Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId) == 0);

    // Place down another thermo beside it
    console.log("build neighbour");
    console.logBytes32(thermoEntity.entityId);
    VoxelCoord memory thermoCoord2 = VoxelCoord({ x: thermoCoord.x, y: thermoCoord.y, z: thermoCoord.z + 1 });
    vm.roll(block.number + 1);
    VoxelEntity memory thermoEntity2 = world.buildWithAgent(ThermoVoxelID, thermoCoord2, agentEntity, bytes4(0));
    assertTrue(Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity2.scale, thermoEntity2.entityId) == 0);
    uint256 temperature2 = Temperature.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      thermoEntity2.scale,
      thermoEntity2.entityId
    );
    console.logUint(temperature2);
    assertTrue(temperature2 > 0);

    vm.stopPrank();
  }

  function testThermoWithTwoValidThermoNeighbour() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory thermoCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory thermoEntity = world.buildWithAgent(ThermoVoxelID, thermoCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId, INITIAL_HIGH_ENERGY);
    world.activateWithAgent(ThermoVoxelID, thermoCoord, agentEntity, bytes4(0));
    uint256 temperature = Temperature.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      thermoEntity.scale,
      thermoEntity.entityId
    );
    console.log("temperature");
    console.logUint(temperature);
    assertTrue(temperature > 0);
    assertTrue(Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId) == 0);

    // Place down another thermo beside it
    console.log("build neighbour");
    console.logBytes32(thermoEntity.entityId);
    VoxelCoord memory thermoCoord2 = VoxelCoord({ x: thermoCoord.x, y: thermoCoord.y, z: thermoCoord.z + 1 });
    vm.roll(block.number + 1);
    VoxelEntity memory thermoEntity2 = world.buildWithAgent(ThermoVoxelID, thermoCoord2, agentEntity, bytes4(0));
    assertTrue(Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity2.scale, thermoEntity2.entityId) == 0);
    uint256 temperature2 = Temperature.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      thermoEntity2.scale,
      thermoEntity2.entityId
    );
    console.log("temperature2");
    console.logUint(temperature2);
    assertTrue(temperature2 > 0);

    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x, y: agentCoord.y, z: agentCoord.z + 1 });
    (, agentEntity) = world.moveWithAgent(FaucetVoxelID, agentCoord, newAgentCoord, agentEntity);

    console.log("build neighbour 2");
    console.logBytes32(thermoEntity.entityId);
    VoxelCoord memory thermoCoord3 = VoxelCoord({ x: thermoCoord2.x, y: thermoCoord2.y, z: thermoCoord2.z + 1 });
    vm.roll(block.number + 1);
    VoxelEntity memory thermoEntity3 = world.buildWithAgent(ThermoVoxelID, thermoCoord3, agentEntity, bytes4(0));
    // assertTrue(Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity3.scale, thermoEntity3.entityId) == 0);
    uint256 temperature3 = Temperature.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      thermoEntity3.scale,
      thermoEntity3.entityId
    );
    console.log("temperature3");
    console.logUint(temperature3);
    assertTrue(temperature3 > 0);
    assertTrue(
      Temperature.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity2.scale, thermoEntity2.entityId) <
        temperature2
    );

    vm.stopPrank();
  }

  function testThermoWithNonFireAgent() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    // Agent is already non-fire agent
    VoxelEntity memory agentEntity = setupAgent();

    HealthData memory initialHealth = Health.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    assertTrue(initialHealth.health > 0);
    assertTrue(initialHealth.lastUpdateBlock == 0);

    VoxelCoord memory thermoCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    vm.roll(block.number + 1);
    console.log("building");
    VoxelEntity memory thermoEntity = world.buildWithAgent(ThermoVoxelID, thermoCoord, agentEntity, bytes4(0));
    uint256 difference = 10;
    uint256 initialEnergy = initialHealth.health + difference;
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId, initialEnergy);
    world.activateWithAgent(ThermoVoxelID, thermoCoord, agentEntity, bytes4(0));
    uint256 temperature = Temperature.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      thermoEntity.scale,
      thermoEntity.entityId
    );
    console.log("temperature");
    console.logUint(temperature);
    assertTrue(temperature == initialEnergy - difference); // ie lost 10
    assertTrue(Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId) == 0);

    HealthData memory newHealth = Health.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    console.log("newHealth");
    console.logUint(initialHealth.health);
    console.logUint(newHealth.health);
    assertTrue(newHealth.health == initialHealth.health - difference);
    assertTrue(newHealth.lastUpdateBlock == block.number);

    vm.stopPrank();
  }

  function testThermoWithFireAgent() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    // Agent is already non-fire agent
    VoxelEntity memory faucetEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord({ x: 50, y: 10, z: 50 }))
    });
    VoxelEntity memory agentEntity = world.claimAgentFromFaucet(faucetEntity, FirePokemonVoxelID, agentCoord);
    Health.setHealth(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId, 500);

    HealthData memory initialHealth = Health.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    assertTrue(initialHealth.health > 0);
    assertTrue(initialHealth.lastUpdateBlock == 0);

    VoxelCoord memory thermoCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    vm.roll(block.number + 1);
    console.log("building");
    VoxelEntity memory thermoEntity = world.buildWithAgent(ThermoVoxelID, thermoCoord, agentEntity, bytes4(0));
    uint256 difference = 10;
    uint256 initialEnergy = initialHealth.health + difference;
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId, initialEnergy);
    world.activateWithAgent(ThermoVoxelID, thermoCoord, agentEntity, bytes4(0));
    uint256 temperature = Temperature.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      thermoEntity.scale,
      thermoEntity.entityId
    );
    console.log("temperature");
    console.logUint(temperature);
    assertTrue(temperature == initialEnergy - difference); // ie lost 10
    assertTrue(Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId) == 0);

    HealthData memory newHealth = Health.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    console.log("newHealth");
    console.logUint(initialHealth.health);
    console.logUint(newHealth.health);
    assertTrue(newHealth.health == initialHealth.health + difference);
    assertTrue(newHealth.lastUpdateBlock == block.number);

    vm.stopPrank();
  }

  function testThermoLaunch() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory thermoCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory thermoEntity = world.buildWithAgent(ThermoVoxelID, thermoCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId, INITIAL_HIGH_ENERGY);
    world.activateWithAgent(ThermoVoxelID, thermoCoord, agentEntity, bytes4(0));
    uint256 temperature = Temperature.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      thermoEntity.scale,
      thermoEntity.entityId
    );
    console.log("temperature");
    console.logUint(temperature);
    assertTrue(temperature > 0);
    assertTrue(Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId) == 0);

    // Place down dirt on top of it
    console.log("build neighbour");
    console.logBytes32(thermoEntity.entityId);
    VoxelCoord memory dirtCoord = VoxelCoord({ x: thermoCoord.x, y: thermoCoord.y + 1, z: thermoCoord.z });
    vm.roll(block.number + 1);
    VoxelEntity memory dirtEntity = world.buildWithAgent(DirtVoxelID, dirtCoord, agentEntity, bytes4(0));
    console.log("types");
    console.logInt(thermoCoord.x);
    console.logInt(thermoCoord.y);
    console.logInt(thermoCoord.z);
    VoxelEntity memory accDirtEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(thermoCoord.x, thermoCoord.y + 1, thermoCoord.z + 4))
    });
    assertTrue(VoxelType.getVoxelTypeId(accDirtEntity.scale, accDirtEntity.entityId) == DirtVoxelID);
    VoxelCoord memory dirtVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, accDirtEntity.scale, accDirtEntity.entityId),
      (VoxelCoord)
    );
    console.log("dirtVelocity");
    console.logInt(dirtVelocity.x);
    console.logInt(dirtVelocity.y);
    console.logInt(dirtVelocity.z);
    console.log("temperature");
    assertTrue(dirtVelocity.x == 0);
    assertTrue(dirtVelocity.y == 0);
    assertTrue(dirtVelocity.z == 4);
    console.logUint(
      Temperature.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId)
    );
    assertTrue(
      Temperature.get(IStore(SIMULATOR_ADDRESS), worldAddress, thermoEntity.scale, thermoEntity.entityId) < temperature
    );

    vm.stopPrank();
  }
}
