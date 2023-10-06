// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelType, OwnedBy } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, Mind } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { FighterVoxelID, GrassVoxelID, AirVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { MindRegistry } from "@tenet-registry/src/codegen/tables/MindRegistry.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { SoilVoxelID, PlantVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

uint256 constant INITIAL_HIGH_ENERGY = 1000;

contract SoilTest is MudTest {
  IWorld private world;
  IStore private store;
  VoxelCoord private agentCoord;

  address payable internal alice;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    agentCoord = VoxelCoord(11, 2, 10);
  }

  function setupAgent() internal returns (VoxelEntity memory) {
    // Claim agent
    VoxelEntity memory faucetEntity = VoxelEntity({ scale: 1, entityId: getEntityAtCoord(1, VoxelCoord(10, 2, 10)) });
    VoxelEntity memory agentEntity = world.claimAgentFromFaucet(faucetEntity, FighterVoxelID, agentCoord);
    return agentEntity;
  }

  function testSoilWithSoilNeighbour() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, INITIAL_HIGH_ENERGY);
    uint256 soil1Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy == INITIAL_HIGH_ENERGY);

    // Place down another soil beside it
    VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x, y: soilCoord.y, z: soilCoord.z + 1 });
    VoxelEntity memory soilEntity2 = world.buildWithAgent(SoilVoxelID, soilCoord2, agentEntity, bytes4(0));
    assertTrue(
      Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) < soil1Energy
    );
    uint256 soil2Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId);
    assertTrue(soil2Energy > 0);

    vm.stopPrank();
  }

  function testSoilWithPlantNeighbour() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, INITIAL_HIGH_ENERGY);
    uint256 soil1Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy == INITIAL_HIGH_ENERGY);

    // Place down plant on top of it
    vm.roll(block.number + 1);
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    uint256 plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > 0);

    // Roll forward and activate soil
    vm.roll(block.number + 1);
    world.activateWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    // Plant should have even more energy
    uint256 plantEnergy2 = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy2 > plantEnergy);

    vm.stopPrank();
  }

  function testSoilWithSoilAndPlantNeighbour() public {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    uint256 soil1Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy == 0);

    // Place down another soil beside it
    VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x, y: soilCoord.y, z: soilCoord.z + 1 });
    VoxelEntity memory soilEntity2 = world.buildWithAgent(SoilVoxelID, soilCoord2, agentEntity, bytes4(0));
    uint256 soil2Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId);
    assertTrue(soil2Energy == 0);

    // Place down plant on top of it
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    uint256 plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy == 0);

    // Set energy and activate
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, INITIAL_HIGH_ENERGY);
    vm.roll(block.number + 1);
    world.activateWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    // Soil1 should have energy
    soil1Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy > 0);
    // Soil2 should have energy
    soil2Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId);
    assertTrue(soil2Energy > 0);
    // Plant should have energy
    plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > 0);

    vm.stopPrank();
  }

  function testSoilWithZeroEnergy() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    uint256 soilEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soilEnergy == 0);

    // Place down plant on top of it
    {
      VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
      VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
      uint256 plantEnergy = Energy.get(
        IStore(SIMULATOR_ADDRESS),
        worldAddress,
        plantEntity.scale,
        plantEntity.entityId
      );
      assertTrue(plantEnergy == 0);
    }

    // Move agent to soil
    {
      // Place down another soil beside it
      VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x, y: soilCoord.y, z: soilCoord.z + 1 });
      VoxelEntity memory soilEntity2 = world.buildWithAgent(SoilVoxelID, soilCoord2, agentEntity, bytes4(0));
      assertTrue(Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) == 0);
      uint256 soil2Energy = Energy.get(
        IStore(SIMULATOR_ADDRESS),
        worldAddress,
        soilEntity2.scale,
        soilEntity2.entityId
      );
      assertTrue(soil2Energy == 0);
    }

    vm.stopPrank();
  }
}
