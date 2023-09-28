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
import { BodyPhysics, BodyPhysicsData } from "@tenet-world/src/codegen/tables/BodyPhysics.sol";
import { MindRegistry } from "@tenet-registry/src/codegen/tables/MindRegistry.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { EnergySourceVoxelID, SoilVoxelID, PlantVoxelID, PokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { ENERGY_SOURCE_WAIT_BLOCKS } from "@tenet-pokemon-extension/src/systems/voxel-interactions/EnergySourceSystem.sol";
import { ENERGY_REQUIRED_FOR_SPROUT, ENERGY_REQUIRED_FOR_FLOWER } from "@tenet-pokemon-extension/src/systems/voxel-interactions/PlantSystem.sol";

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
    alice = payable(address(0x1));
    agentCoord = VoxelCoord(10, 2, 10);
    energySourceCoord = VoxelCoord(10, 2, 11);
  }

  function setupAgent() internal returns (VoxelEntity memory) {
    // Claim agent
    VoxelEntity memory agentEntity = VoxelEntity({ scale: 1, entityId: getEntityAtCoord(1, agentCoord) });
    world.claimAgent(agentEntity);
    return agentEntity;
  }

  function replaceHighEnergyBlockWithEnergySource(
    VoxelEntity memory agentEntity
  ) internal returns (VoxelEntity memory) {
    VoxelEntity memory highEnergyEntity = VoxelEntity({ scale: 1, entityId: getEntityAtCoord(1, energySourceCoord) });

    // Mine block with high energy
    world.mineWithAgent(GrassVoxelID, energySourceCoord, agentEntity);

    // Place down energy source
    VoxelEntity memory energySourceEntity = world.buildWithAgent(
      EnergySourceVoxelID,
      energySourceCoord,
      agentEntity,
      bytes4(0)
    );
    return energySourceEntity;
  }

  function testPlantSeedStage() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice);

    VoxelEntity memory agentEntity = setupAgent();
    VoxelEntity memory energySourceEntity = replaceHighEnergyBlockWithEnergySource(agentEntity);

    // Place down soil beside it
    VoxelCoord memory soilCoord = VoxelCoord({
      x: energySourceCoord.x - 1,
      y: energySourceCoord.y,
      z: energySourceCoord.z
    });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));

    // Some energy should have been transferred to the soil
    uint256 soilEnergy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    assertTrue(soilEnergy > 0);

    // Place down plant on top of it
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    bytes32 plantCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, plantEntity.entityId);
    PlantData memory plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    uint256 plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > 0 && plantEnergy < ENERGY_REQUIRED_FOR_SPROUT);
    assertTrue(plantData.stage == PlantStage.Seed);

    vm.stopPrank();

    return (agentEntity, energySourceEntity);
  }

  function testPlantSproutStage() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice);

    VoxelEntity memory agentEntity = setupAgent();
    VoxelEntity memory energySourceEntity = replaceHighEnergyBlockWithEnergySource(agentEntity);

    // Place down soil beside it
    VoxelCoord memory soilCoord = VoxelCoord({
      x: energySourceCoord.x - 1,
      y: energySourceCoord.y,
      z: energySourceCoord.z
    });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));

    // Some energy should have been transferred to the soil
    uint256 soilEnergy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    assertTrue(soilEnergy > 0);

    // Place down plant on top of it
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    bytes32 plantCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, plantEntity.entityId);
    PlantData memory plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    uint256 plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > 0 && plantEnergy < ENERGY_REQUIRED_FOR_SPROUT);
    assertTrue(plantData.stage == PlantStage.Seed);

    // Roll forward and activate energy source
    vm.roll(block.number + ENERGY_SOURCE_WAIT_BLOCKS + 1);
    world.activateWithAgent(EnergySourceVoxelID, energySourceCoord, agentEntity, bytes4(0));
    plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    soilEnergy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > ENERGY_REQUIRED_FOR_SPROUT && plantEnergy < ENERGY_REQUIRED_FOR_FLOWER);
    assertTrue(plantData.stage == PlantStage.Sprout);

    // Mine soil
    vm.roll(block.number + 10);
    world.mineWithAgent(SoilVoxelID, soilCoord, agentEntity);
    plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    assertTrue(plantData.stage == PlantStage.Sprout);
    vm.roll(block.number + 10);
    // Place down plant next to plant, so it runs out of energy and dies
    VoxelCoord memory plantCoord2 = VoxelCoord({ x: plantCoord.x, y: plantCoord.y, z: plantCoord.z - 1 });
    VoxelEntity memory plantEntity2 = world.buildWithAgent(PlantVoxelID, plantCoord2, agentEntity, bytes4(0));
    assertTrue(BodyPhysics.getEnergy(plantEntity2.scale, plantEntity2.entityId) > 0);
    assertTrue(VoxelType.getVoxelTypeId(plantEntity.scale, plantEntity.entityId) == AirVoxelID);

    vm.stopPrank();

    return (agentEntity, energySourceEntity);
  }

  function testPlantFlowerStage() public {
    vm.startPrank(alice);

    VoxelEntity memory agentEntity = setupAgent();
    VoxelEntity memory energySourceEntity = replaceHighEnergyBlockWithEnergySource(agentEntity);

    // Place down soil beside it
    VoxelCoord memory soilCoord = VoxelCoord({
      x: energySourceCoord.x - 1,
      y: energySourceCoord.y,
      z: energySourceCoord.z
    });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));

    // Some energy should have been transferred to the soil
    uint256 soilEnergy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    assertTrue(soilEnergy > 0);

    // Place down plant on top of it
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    bytes32 plantCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, plantEntity.entityId);
    PlantData memory plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    uint256 plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > 0 && plantEnergy < ENERGY_REQUIRED_FOR_SPROUT);
    assertTrue(plantData.stage == PlantStage.Seed);

    // Roll forward and activate energy source
    vm.roll(block.number + ENERGY_SOURCE_WAIT_BLOCKS + 1);
    world.activateWithAgent(EnergySourceVoxelID, energySourceCoord, agentEntity, bytes4(0));
    plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    soilEnergy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > ENERGY_REQUIRED_FOR_SPROUT && plantEnergy < ENERGY_REQUIRED_FOR_FLOWER);
    assertTrue(plantData.stage == PlantStage.Sprout);

    // Roll forward and activate energy source
    vm.roll(block.number + ENERGY_SOURCE_WAIT_BLOCKS + 1);
    world.activateWithAgent(EnergySourceVoxelID, energySourceCoord, agentEntity, bytes4(0));
    plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    soilEnergy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy >= ENERGY_REQUIRED_FOR_FLOWER);
    assertTrue(plantData.stage == PlantStage.Flower);

    // Place pokemon next to flower
    VoxelCoord memory pokemonCoord = VoxelCoord({ x: plantCoord.x, y: plantCoord.y, z: plantCoord.z - 1 });
    VoxelEntity memory pokemonEntity = world.buildWithAgent(PokemonVoxelID, pokemonCoord, agentEntity, bytes4(0));
    // pokemon entity should have some energy
    plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy == 0);
    assertTrue(BodyPhysics.getEnergy(pokemonEntity.scale, pokemonEntity.entityId) > 0);

    vm.stopPrank();
  }
}
