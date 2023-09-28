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

uint256 constant INITIAL_HIGH_ENERGY = 1000;

contract EnergySourceTest is MudTest {
  IWorld private world;
  IStore private store;
  VoxelCoord private energySourceCoord;

  address payable internal alice;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    alice = payable(address(0x1));
    energySourceCoord = VoxelCoord(10, 2, 11);
  }

  function setupAgent() internal returns (VoxelEntity memory) {
    VoxelCoord memory agentCoord = VoxelCoord(10, 2, 10);
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

  function testEnergySourceNoNeighbours() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory energySourceEntity = replaceHighEnergyBlockWithEnergySource(agentEntity);
    uint256 energySourceEnergy = BodyPhysics.getEnergy(energySourceEntity.scale, energySourceEntity.entityId);
    assertTrue(energySourceEnergy == INITIAL_HIGH_ENERGY);

    vm.stopPrank();

    return (agentEntity, energySourceEntity);
  }

  function testEnergySourceWithOneSoilNeighbour() public {
    console.log("build energy source");
    (VoxelEntity memory agentEntity, VoxelEntity memory energySourceEntity) = testEnergySourceNoNeighbours();
    vm.startPrank(alice);

    // Place down soil beside it
    VoxelCoord memory soilCoord = VoxelCoord({
      x: energySourceCoord.x - 1,
      y: energySourceCoord.y,
      z: energySourceCoord.z
    });
    console.log("build now soil");
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    // Some energy should have been transferred to the soil
    uint256 soilEnergy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    assertTrue(soilEnergy > 0 && soilEnergy <= INITIAL_HIGH_ENERGY);
    // // Energy source should have lost some energy
    // uint256 energySourceEnergy = BodyPhysics.getEnergy(energySourceEntity.scale, energySourceEntity.entityId);
    // assertTrue(energySourceEnergy < INITIAL_HIGH_ENERGY);

    // Roll forward and activate energy source
    // vm.roll(block.number + ENERGY_SOURCE_WAIT_BLOCKS + 1);
    // world.activateWithAgent(EnergySourceVoxelID, energySourceCoord, agentEntity, bytes4(0));
    // // This should have transferred more energy to the soil
    // uint256 soilEnergy2 = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    // assertTrue(soilEnergy2 > soilEnergy);
    // // Energy source should have lost some energy
    // uint256 energySourceEnergy2 = BodyPhysics.getEnergy(energySourceEntity.scale, energySourceEntity.entityId);
    // assertTrue(energySourceEnergy2 < energySourceEnergy);

    vm.stopPrank();
  }

  function testEnergySourceWithTwoSoilNeighbours() public {
    vm.startPrank(alice);
    VoxelEntity memory agentEntity = setupAgent();

    // Place down soil 1
    VoxelCoord memory soil1Coord = VoxelCoord({
      x: energySourceCoord.x - 1,
      y: energySourceCoord.y,
      z: energySourceCoord.z
    });
    VoxelEntity memory soil1Entity = world.buildWithAgent(SoilVoxelID, soil1Coord, agentEntity, bytes4(0));
    uint256 soil1Energy = BodyPhysics.getEnergy(soil1Entity.scale, soil1Entity.entityId);
    assertTrue(soil1Energy == 0);
    // Place down soil 2
    VoxelCoord memory soil2Coord = VoxelCoord({
      x: energySourceCoord.x + 1,
      y: energySourceCoord.y,
      z: energySourceCoord.z
    });
    VoxelEntity memory soil2Entity = world.buildWithAgent(SoilVoxelID, soil2Coord, agentEntity, bytes4(0));
    uint256 soil2Energy = BodyPhysics.getEnergy(soil2Entity.scale, soil2Entity.entityId);
    assertTrue(soil2Energy == 0);

    // Place down energy source
    VoxelEntity memory energySourceEntity = replaceHighEnergyBlockWithEnergySource(agentEntity);
    uint256 energySourceEnergy = BodyPhysics.getEnergy(energySourceEntity.scale, energySourceEntity.entityId);
    assertTrue(energySourceEnergy < INITIAL_HIGH_ENERGY);

    soil1Energy = BodyPhysics.getEnergy(soil1Entity.scale, soil1Entity.entityId);
    soil2Energy = BodyPhysics.getEnergy(soil2Entity.scale, soil2Entity.entityId);

    assertTrue(soil1Energy > 0 && soil1Energy <= INITIAL_HIGH_ENERGY);
    assertTrue(soil2Energy > 0 && soil2Energy <= INITIAL_HIGH_ENERGY);
    assertTrue(soil1Energy == soil2Energy);

    vm.stopPrank();
  }

  function testEnergySourceWithEnergySourceNeighbour() public {
    (VoxelEntity memory agentEntity, VoxelEntity memory energySourceEntity) = testEnergySourceNoNeighbours();
    vm.startPrank(alice);

    VoxelCoord memory energySource2Coord = VoxelCoord({
      x: energySourceCoord.x - 1,
      y: energySourceCoord.y,
      z: energySourceCoord.z
    });
    world.buildWithAgent(EnergySourceVoxelID, energySource2Coord, agentEntity, bytes4(0));

    vm.stopPrank();
  }

  function testEnergySourceWithNoEnergy() public {
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
      x: energySourceNoEnergyCoord.x - 1,
      y: energySourceNoEnergyCoord.y,
      z: energySourceNoEnergyCoord.z
    });
    VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, soilCoord, agentEntity, bytes4(0));
    // Soil should have no energy
    uint256 soilEnergy = BodyPhysics.getEnergy(soilEntity.scale, soilEntity.entityId);
    assertTrue(soilEnergy == 0);

    vm.stopPrank();
  }
}
