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
import { DiffusiveSoilVoxelID, ProteinSoilVoxelID, ElixirSoilVoxelID, PlantVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
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
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Potassium } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { Protein } from "@tenet-simulator/src/codegen/tables/Protein.sol";
import { Elixir } from "@tenet-simulator/src/codegen/tables/Elixir.sol";

uint256 constant INITIAL_HIGH_ENERGY = 150;

contract DiffusiveSoilSoilTest is MudTest {
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
    Health.set(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId, 500);
    return agentEntity;
  }

  function testDiffusiveSoilWithSoilNeighbour() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(DiffusiveSoilVoxelID, soilCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, INITIAL_HIGH_ENERGY);
    uint256 soil1Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy == INITIAL_HIGH_ENERGY);
    world.activateWithAgent(DiffusiveSoilVoxelID, soilCoord, agentEntity, bytes4(0));
    uint256 soil1Nutrients = Nutrients.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      soilEntity.scale,
      soilEntity.entityId
    );
    assertTrue(soil1Nutrients > 0);
    assertTrue(Nitrogen.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
    assertTrue(Phosphorous.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
    assertTrue(Potassium.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);

    // Place down another soil beside it
    VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x, y: soilCoord.y, z: soilCoord.z + 1 });
    VoxelEntity memory soilEntity2 = world.buildWithAgent(DiffusiveSoilVoxelID, soilCoord2, agentEntity, bytes4(0));
    uint256 soil2Nutrients = Nutrients.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      soilEntity2.scale,
      soilEntity2.entityId
    );
    assertTrue(soil2Nutrients == 0);
    assertTrue(Nitrogen.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId) > 0);
    assertTrue(Phosphorous.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId) > 0);
    assertTrue(Potassium.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId) > 0);

    vm.stopPrank();
  }

  function testDiffusiveSoilWithPlantNeighbour() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(DiffusiveSoilVoxelID, soilCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, INITIAL_HIGH_ENERGY);
    uint256 soil1Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy == INITIAL_HIGH_ENERGY);
    world.activateWithAgent(DiffusiveSoilVoxelID, soilCoord, agentEntity, bytes4(0));
    uint256 soilNutrients = Nutrients.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      soilEntity.scale,
      soilEntity.entityId
    );
    console.log("soilNutrients");
    console.logUint(soilNutrients);
    assertTrue(soilNutrients > 0);
    assertTrue(Nitrogen.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
    assertTrue(Phosphorous.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
    assertTrue(Potassium.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);

    // Place down plant on top of it
    vm.roll(block.number + 1);
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    assertTrue(Elixir.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId) > 0);
    assertTrue(Protein.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId) > 0);
    assertTrue(Nitrogen.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId) > 0);
    assertTrue(Phosphorous.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId) > 0);
    assertTrue(Potassium.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testDiffusiveSoilWithSoilAndPlantNeighbour() public {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(DiffusiveSoilVoxelID, soilCoord, agentEntity, bytes4(0));
    uint256 soil1Nutrients = Nutrients.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      soilEntity.scale,
      soilEntity.entityId
    );
    assertTrue(soil1Nutrients == 0);
    assertTrue(Nitrogen.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
    assertTrue(Phosphorous.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
    assertTrue(Potassium.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);

    // Place down another soil beside it
    VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x, y: soilCoord.y, z: soilCoord.z + 1 });
    VoxelEntity memory soilEntity2 = world.buildWithAgent(DiffusiveSoilVoxelID, soilCoord2, agentEntity, bytes4(0));
    uint256 soil2Nutrients = Nutrients.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      soilEntity2.scale,
      soilEntity2.entityId
    );
    assertTrue(soil2Nutrients == 0);
    assertTrue(Nitrogen.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId) > 0);
    assertTrue(Phosphorous.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId) > 0);
    assertTrue(Potassium.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId) > 0);

    // Place down plant on top of it
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, plantCoord, agentEntity, bytes4(0));
    uint256 plantNutrients = Nutrients.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      plantEntity.scale,
      plantEntity.entityId
    );
    assertTrue(plantNutrients == 0);
    assertTrue(Nitrogen.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId) > 0);
    assertTrue(Phosphorous.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId) > 0);
    assertTrue(Potassium.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId) > 0);

    // Set energy and activate
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, INITIAL_HIGH_ENERGY);
    vm.roll(block.number + 1);
    console.log("activate");
    world.activateWithAgent(ElixirSoilVoxelID, soilCoord, agentEntity, bytes4(0));
    // // Soil1 should have nutrients
    soil1Nutrients = Nutrients.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Nutrients == 0);
    // Soil2 should have nutrients
    soil2Nutrients = Nutrients.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId);
    assertTrue(soil2Nutrients == 0);
    // Plant should have nutrients
    assertTrue(Elixir.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId) > 0);
    assertTrue(Protein.get(IStore(SIMULATOR_ADDRESS), worldAddress, plantEntity.scale, plantEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testDiffusiveSoilBehaviour() public returns (VoxelEntity memory, VoxelEntity memory) {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(DiffusiveSoilVoxelID, soilCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, INITIAL_HIGH_ENERGY);
    uint256 soil1Energy = Energy.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId);
    assertTrue(soil1Energy == INITIAL_HIGH_ENERGY);
    world.activateWithAgent(DiffusiveSoilVoxelID, soilCoord, agentEntity, bytes4(0));
    uint256 soil1Nutrients = Nutrients.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      soilEntity.scale,
      soilEntity.entityId
    );
    assertTrue(soil1Nutrients > 0);
    assertTrue(Nitrogen.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
    assertTrue(Phosphorous.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
    assertTrue(Potassium.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);

    // Place down another soil beside it
    VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x, y: soilCoord.y, z: soilCoord.z + 1 });
    VoxelEntity memory soilEntity2 = world.buildWithAgent(DiffusiveSoilVoxelID, soilCoord2, agentEntity, bytes4(0));
    uint256 soil2Nutrients = Nutrients.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      soilEntity2.scale,
      soilEntity2.entityId
    );
    assertTrue(soil2Nutrients == 0);
    assertTrue(Nitrogen.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId) > 0);
    assertTrue(Phosphorous.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId) > 0);
    assertTrue(Potassium.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId) > 0);
    uint256 soil2BeforeNutrients = soil1Nutrients + 10;
    Nutrients.set(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      soilEntity2.scale,
      soilEntity2.entityId,
      soil2BeforeNutrients
    );

    vm.roll(block.number + 1);
    console.log("activate");
    world.activateWithAgent(DiffusiveSoilVoxelID, soilCoord2, agentEntity, bytes4(0));
    assertTrue(
      Nutrients.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity2.scale, soilEntity2.entityId) <
        soil2BeforeNutrients
    );
    assertTrue(
      Nutrients.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > soil1Nutrients
    );

    vm.stopPrank();
  }
}