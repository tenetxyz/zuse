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
import { EnergySourceVoxelID, SoilVoxelID, PlantVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { ENERGY_SOURCE_WAIT_BLOCKS } from "@tenet-pokemon-extension/src/systems/voxel-interactions/EnergySourceSystem.sol";

contract SoilTest is MudTest {
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

  function testSoilWithSoilNeighbour() public returns (VoxelEntity memory, VoxelEntity memory) {
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
    uint256 soil1Energy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy > 0);

    // Move agent to soil
    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x - 1, y: agentCoord.y, z: agentCoord.z });
    (, agentEntity) = world.moveWithAgent(FighterVoxelID, agentCoord, newAgentCoord, agentEntity);

    // Place down another soil beside it
    VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x - 1, y: soilCoord.y, z: soilCoord.z });
    VoxelEntity memory soilEntity2 = world.buildWithAgent(SoilVoxelID, soilCoord2, agentEntity, bytes4(0));
    assertTrue(BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId) < soil1Energy);
    uint256 soil2Energy = BodyPhysics.getEnergy(soilEntity2.scale, soilEntity2.entityId);
    assertTrue(soil2Energy > 0);

    vm.stopPrank();

    return (agentEntity, energySourceEntity);
  }

  function testSoilWithPlantNeighbour() public returns (VoxelEntity memory, VoxelEntity memory) {
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
    uint256 plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > 0);

    // Roll forward and activate soil
    vm.roll(block.number + ENERGY_SOURCE_WAIT_BLOCKS + 1);
    world.activateWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    // Plant should have even more energy
    uint256 plantEnergy2 = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy2 > plantEnergy);

    vm.stopPrank();

    return (agentEntity, energySourceEntity);
  }

  function testSoilWithSoilAndPlantNeighbour() public {
    vm.startPrank(alice);
    VoxelEntity memory agentEntity = setupAgent();

    // Place down soil beside it
    VoxelCoord memory soilCoord = VoxelCoord({
      x: energySourceCoord.x - 1,
      y: energySourceCoord.y,
      z: energySourceCoord.z
    });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));

    // Some energy should have been transferred to the soil
    uint256 soil1Energy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy == 0);

    // Move agent to soil
    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x - 1, y: agentCoord.y, z: agentCoord.z });
    (, agentEntity) = world.moveWithAgent(FighterVoxelID, agentCoord, newAgentCoord, agentEntity);

    // Place down another soil beside it
    VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x - 1, y: soilCoord.y, z: soilCoord.z });
    VoxelEntity memory soilEntity2 = world.buildWithAgent(SoilVoxelID, soilCoord2, agentEntity, bytes4(0));
    uint256 soil2Energy = BodyPhysics.getEnergy(soilEntity2.scale, soilEntity2.entityId);
    assertTrue(soil2Energy == 0);

    // Place down plant on top of it
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    uint256 plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy == 0);

    // Place down energy source
    VoxelEntity memory energySourceEntity = replaceHighEnergyBlockWithEnergySource(agentEntity);
    // Soil1 should have energy
    soil1Energy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy > 0);
    // Soil2 should have energy
    soil2Energy = BodyPhysics.getEnergy(soilEntity2.scale, soilEntity2.entityId);
    assertTrue(soil2Energy > 0);
    // Plant should have energy
    plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
    assertTrue(plantEnergy > 0);

    vm.stopPrank();
  }

  function testSoilWithZeroEnergy() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory energySourceNoEnergyCoord = VoxelCoord({
      x: energySourceCoord.x,
      y: energySourceCoord.y + 1,
      z: energySourceCoord.z
    });

    // Place down energy source
    VoxelEntity memory energySourceEntity = world.buildWithAgent(
      EnergySourceVoxelID,
      energySourceNoEnergyCoord,
      agentEntity,
      bytes4(0)
    );
    uint256 energySourceEnergy = BodyPhysics.getEnergy(energySourceEntity.scale, energySourceEntity.entityId);
    assertTrue(energySourceEnergy == 0);

    // Place down soil beside it
    VoxelCoord memory soilCoord = VoxelCoord({
      x: energySourceCoord.x - 1,
      y: energySourceCoord.y,
      z: energySourceCoord.z
    });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));

    uint256 soilEnergy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    assertTrue(soilEnergy == 0);

    // Place down plant on top of it
    {
      VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
      VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
      uint256 plantEnergy = BodyPhysics.getEnergy(plantEntity.scale, plantEntity.entityId);
      assertTrue(plantEnergy == 0);
    }

    // Move agent to soil
    {
      VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x - 1, y: agentCoord.y, z: agentCoord.z });
      (, agentEntity) = world.moveWithAgent(FighterVoxelID, agentCoord, newAgentCoord, agentEntity);

      // Place down another soil beside it
      VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x - 1, y: soilCoord.y, z: soilCoord.z });
      VoxelEntity memory soilEntity2 = world.buildWithAgent(SoilVoxelID, soilCoord2, agentEntity, bytes4(0));
      assertTrue(BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId) == 0);
      uint256 soil2Energy = BodyPhysics.getEnergy(soilEntity2.scale, soilEntity2.entityId);
      assertTrue(soil2Energy == 0);
    }

    vm.stopPrank();

    return (agentEntity, energySourceEntity);
  }
}
