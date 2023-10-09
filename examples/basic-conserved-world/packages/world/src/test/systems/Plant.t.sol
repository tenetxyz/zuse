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
import { SoilVoxelID, PlantVoxelID, FirePokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { AMOUNT_REQUIRED_FOR_SPROUT, AMOUNT_REQUIRED_FOR_FLOWER } from "@tenet-pokemon-extension/src/systems/voxel-interactions/PlantSystem.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";

contract PlantTest is MudTest {
  IWorld private world;
  IStore private store;
  VoxelCoord private energySourceCoord;
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

  function testPlantSeedStage() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, 150);
    uint256 soil1Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy == 150);

    // Place down plant on top of it
    vm.roll(block.number + 1);
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    bytes32 plantCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, plantEntity.entityId);
    PlantData memory plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    uint256 plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > 0 && plantEnergy < AMOUNT_REQUIRED_FOR_SPROUT);
    assertTrue(plantData.stage == PlantStage.Seed);

    vm.stopPrank();
  }

  function testPlantSproutStage() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, 150);
    uint256 soilEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soilEnergy == 150);

    // Place down plant on top of it
    vm.roll(block.number + 1);
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    bytes32 plantCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, plantEntity.entityId);
    PlantData memory plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    uint256 plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > 0 && plantEnergy < AMOUNT_REQUIRED_FOR_SPROUT);
    assertTrue(plantData.stage == PlantStage.Seed);

    vm.roll(block.number + 1);
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, 110);
    world.activateWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    soilEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    console.logUint(uint(plantData.stage));
    assertTrue(plantEnergy > AMOUNT_REQUIRED_FOR_SPROUT && plantEnergy < AMOUNT_REQUIRED_FOR_FLOWER);
    assertTrue(plantData.stage == PlantStage.Sprout);

    // Mine soil
    vm.roll(block.number + 1);
    world.mineWithAgent(SoilVoxelID, soilCoord, agentEntity);
    plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    assertTrue(plantData.stage == PlantStage.Sprout);
    vm.roll(block.number + 1);
    // Place down plant next to plant, so it runs out of energy and dies
    VoxelCoord memory plantCoord2 = VoxelCoord({ x: plantCoord.x, y: plantCoord.y, z: plantCoord.z - 1 });
    VoxelEntity memory plantEntity2 = world.buildWithAgent(PlantVoxelID, plantCoord2, agentEntity, bytes4(0));
    assertTrue(Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity2.scale, plantEntity2.entityId) > 0);
    assertTrue(VoxelType.getVoxelTypeId(plantEntity.scale, plantEntity.entityId) == AirVoxelID);

    vm.stopPrank();
  }

  function testPlantFlowerStage() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, 150);
    uint256 soilEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soilEnergy == 150);

    // Place down plant on top of it
    vm.roll(block.number + 1);
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    bytes32 plantCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, plantEntity.entityId);
    PlantData memory plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    uint256 plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > 0 && plantEnergy < AMOUNT_REQUIRED_FOR_SPROUT);
    assertTrue(plantData.stage == PlantStage.Seed);

    vm.roll(block.number + 1);
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, 110);
    world.activateWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    soilEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > AMOUNT_REQUIRED_FOR_SPROUT && plantEnergy < AMOUNT_REQUIRED_FOR_FLOWER);
    assertTrue(plantData.stage == PlantStage.Sprout);

    vm.roll(block.number + 1);
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, 1000);
    world.activateWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    soilEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy >= AMOUNT_REQUIRED_FOR_FLOWER);
    assertTrue(plantData.stage == PlantStage.Flower);

    // Place pokemon next to flower
    {
      uint256 beforePokemonPlantEnergy = plantEnergy;
      VoxelCoord memory pokemonCoord = VoxelCoord({ x: plantCoord.x, y: plantCoord.y, z: plantCoord.z - 1 });
      VoxelEntity memory pokemonEntity = world.buildWithAgent(FirePokemonVoxelID, pokemonCoord, agentEntity, bytes4(0));
      // pokemon entity should have some energy
      plantEnergy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId);
      assertTrue(plantEnergy < beforePokemonPlantEnergy);
      assertTrue(Health.get(IStore(SIMULATOR_ADDRESS), worldAddress, pokemonEntity.scale, pokemonEntity.entityId) > 0);
      assertTrue(Stamina.get(IStore(SIMULATOR_ADDRESS), worldAddress, pokemonEntity.scale, pokemonEntity.entityId) > 0);
    }

    vm.stopPrank();
  }
}
