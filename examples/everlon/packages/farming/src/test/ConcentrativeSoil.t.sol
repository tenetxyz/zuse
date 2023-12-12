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
import { ObjectType } from "@tenet-world/src/codegen/tables/ObjectType.sol";
import { OwnedBy } from "@tenet-world/src/codegen/tables/OwnedBy.sol";
import { ObjectEntity } from "@tenet-world/src/codegen/tables/ObjectEntity.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { SIMULATOR_ADDRESS, BuilderObjectID, GrassObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";
import { WORLD_ADDRESS, SOIL_MASS, PlantObjectID, ConcentrativeSoilObjectID, DiffusiveSoilObjectID, ProteinSoilObjectID, ElixirSoilObjectID } from "@tenet-farming/src/Constants.sol";
import { REGISTRY_ADDRESS } from "@tenet-farming/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Nutrients } from "@tenet-simulator/src/codegen/tables/Nutrients.sol";
import { Nitrogen } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorus } from "@tenet-simulator/src/codegen/tables/Phosphorus.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Potassium } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { Protein } from "@tenet-simulator/src/codegen/tables/Protein.sol";
import { Elixir } from "@tenet-simulator/src/codegen/tables/Elixir.sol";

// TODO: Replace relative imports in IWorld.sol, instead of this hack
interface IWorld is IBaseWorld, IBuildSystem, IMineSystem, IMoveSystem, IActivateSystem, IFaucetSystem {

}

contract ConcentrativeSoilTest is MudTest {
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

  function testConcentrativeSoilWithSoilNeighbour() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    bytes32 soilEntityId = world.build(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord);
    bytes32 soilObjectEntityId = ObjectEntity.get(store, soilEntityId);
    assertTrue(Nitrogen.get(simStore, worldAddress, soilObjectEntityId) > 0, "Nitrogen not found");
    assertTrue(Phosphorus.get(simStore, worldAddress, soilObjectEntityId) > 0, "Phosphorus not found");
    assertTrue(Potassium.get(simStore, worldAddress, soilObjectEntityId) > 0, "Potassium not found");
    uint256 soil1Nutrients = Nutrients.get(simStore, worldAddress, soilObjectEntityId);
    // Initially no energy, so no nutrients
    assertTrue(soil1Nutrients == 0, "Soil nutrients not 0");

    vm.roll(block.number + 1);

    Energy.set(simStore, worldAddress, soilObjectEntityId, 150);
    world.activate(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord);
    soil1Nutrients = Nutrients.get(simStore, worldAddress, soilObjectEntityId);
    assertTrue(soil1Nutrients > 0, "Soil nutrients not > 0");

    vm.roll(block.number + 1);

    // Place down another soil beside it
    VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x, y: soilCoord.y, z: soilCoord.z + 1 });
    bytes32 soil2EntityId = world.build(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord2);
    bytes32 soil2ObjectEntityId = ObjectEntity.get(store, soil2EntityId);
    assertTrue(Nitrogen.get(simStore, worldAddress, soil2ObjectEntityId) > 0, "Nitrogen not found for soil 2");
    assertTrue(Phosphorus.get(simStore, worldAddress, soil2ObjectEntityId) > 0, "Phosphorus not found for soil 2");
    assertTrue(Potassium.get(simStore, worldAddress, soil2ObjectEntityId) > 0, "Potassium not found for soil 2");

    uint256 soil2Nutrients = Nutrients.get(simStore, worldAddress, soil2ObjectEntityId);

    // Concentrative soil should not have transferred nutrients to soil 2
    assertTrue(soil2Nutrients == 0, "Soil 2 nutrients not 0");

    vm.stopPrank();
  }

  function testConcentrativeSoilWithPlantNeighbour() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    bytes32 soilEntityId = world.build(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord);
    bytes32 soilObjectEntityId = ObjectEntity.get(store, soilEntityId);
    assertTrue(Nitrogen.get(simStore, worldAddress, soilObjectEntityId) > 0, "Nitrogen not found");
    assertTrue(Phosphorus.get(simStore, worldAddress, soilObjectEntityId) > 0, "Phosphorus not found");
    assertTrue(Potassium.get(simStore, worldAddress, soilObjectEntityId) > 0, "Potassium not found");
    uint256 soil1Nutrients = Nutrients.get(simStore, worldAddress, soilObjectEntityId);
    // Initially no energy, so no nutrients
    assertTrue(soil1Nutrients == 0, "Soil nutrients not 0");

    vm.roll(block.number + 1);

    Energy.set(simStore, worldAddress, soilObjectEntityId, 150);
    world.activate(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord);
    soil1Nutrients = Nutrients.get(simStore, worldAddress, soilObjectEntityId);
    assertTrue(soil1Nutrients > 0, "Soil nutrients not > 0");

    vm.roll(block.number + 1);

    // Place down plant on top of it
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    bytes32 plantEntityId = world.build(agentObjectEntityId, PlantObjectID, plantCoord);
    bytes32 plantObjectEntityId = ObjectEntity.get(store, plantEntityId);
    assertTrue(Nitrogen.get(simStore, worldAddress, plantObjectEntityId) > 0, "Nitrogen not found for plant");
    assertTrue(Phosphorus.get(simStore, worldAddress, plantObjectEntityId) > 0, "Phosphorus not found for plant");
    assertTrue(Potassium.get(simStore, worldAddress, plantObjectEntityId) > 0, "Potassium not found for plant");

    assertTrue(Elixir.get(simStore, worldAddress, plantObjectEntityId) > 0, "Elixir not found for plant");
    assertTrue(Protein.get(simStore, worldAddress, plantObjectEntityId) > 0, "Protein not found for plant");

    vm.stopPrank();
  }

  function testConcentrativeSoilWithSoilAndPlantNeighbour() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    bytes32 soilEntityId = world.build(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord);
    bytes32 soilObjectEntityId = ObjectEntity.get(store, soilEntityId);
    assertTrue(Nitrogen.get(simStore, worldAddress, soilObjectEntityId) > 0, "Nitrogen not found");
    assertTrue(Phosphorus.get(simStore, worldAddress, soilObjectEntityId) > 0, "Phosphorus not found");
    assertTrue(Potassium.get(simStore, worldAddress, soilObjectEntityId) > 0, "Potassium not found");
    uint256 soil1Nutrients = Nutrients.get(simStore, worldAddress, soilObjectEntityId);
    // Initially no energy, so no nutrients
    assertTrue(soil1Nutrients == 0, "Soil nutrients not 0");

    vm.roll(block.number + 1);

    // Place down another soil beside it
    VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x, y: soilCoord.y, z: soilCoord.z + 1 });
    bytes32 soil2EntityId = world.build(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord2);
    bytes32 soil2ObjectEntityId = ObjectEntity.get(store, soil2EntityId);
    assertTrue(Nitrogen.get(simStore, worldAddress, soil2ObjectEntityId) > 0, "Nitrogen not found for soil 2");
    assertTrue(Phosphorus.get(simStore, worldAddress, soil2ObjectEntityId) > 0, "Phosphorus not found for soil 2");
    assertTrue(Potassium.get(simStore, worldAddress, soil2ObjectEntityId) > 0, "Potassium not found for soil 2");

    uint256 soil2Nutrients = Nutrients.get(simStore, worldAddress, soil2ObjectEntityId);

    // Concentrative soil should not have transferred nutrients to soil 2
    assertTrue(soil2Nutrients == 0, "Soil 2 nutrients not 0");

    // Place down plant on top of it
    VoxelCoord memory plantCoord = VoxelCoord({ x: soilCoord.x, y: soilCoord.y + 1, z: soilCoord.z });
    bytes32 plantEntityId = world.build(agentObjectEntityId, PlantObjectID, plantCoord);
    bytes32 plantObjectEntityId = ObjectEntity.get(store, plantEntityId);
    assertTrue(Nitrogen.get(simStore, worldAddress, plantObjectEntityId) > 0, "Nitrogen not found for plant");
    assertTrue(Phosphorus.get(simStore, worldAddress, plantObjectEntityId) > 0, "Phosphorus not found for plant");
    assertTrue(Potassium.get(simStore, worldAddress, plantObjectEntityId) > 0, "Potassium not found for plant");

    assertTrue(Elixir.get(simStore, worldAddress, plantObjectEntityId) == 0, "Elixir should not be found for plant");
    assertTrue(Protein.get(simStore, worldAddress, plantObjectEntityId) == 0, "Protein should not be found for plant");

    vm.roll(block.number + 1);

    Energy.set(simStore, worldAddress, soilObjectEntityId, 150);
    world.activate(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord);

    // Soil1 should have no nutrients, since transferred all to plant
    soil1Nutrients = Nutrients.get(simStore, worldAddress, soilObjectEntityId);
    assertTrue(soil1Nutrients == 0, "Soil nutrients not 0");

    // Soil2 should have some nutrients from the energy flux
    soil2Nutrients = Nutrients.get(simStore, worldAddress, soil2ObjectEntityId);
    assertTrue(soil2Nutrients > 0, "Soil 2 nutrients not 0");

    // Plant should have elixir and protein
    assertTrue(Elixir.get(simStore, worldAddress, plantObjectEntityId) > 0, "Elixir not found for plant");
    assertTrue(Protein.get(simStore, worldAddress, plantObjectEntityId) > 0, "Protein not found for plant");

    vm.stopPrank();
  }

  function testConcentrativeSoilBehaviour() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    bytes32 soilEntityId = world.build(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord);
    bytes32 soilObjectEntityId = ObjectEntity.get(store, soilEntityId);
    assertTrue(Nitrogen.get(simStore, worldAddress, soilObjectEntityId) > 0, "Nitrogen not found");
    assertTrue(Phosphorus.get(simStore, worldAddress, soilObjectEntityId) > 0, "Phosphorus not found");
    assertTrue(Potassium.get(simStore, worldAddress, soilObjectEntityId) > 0, "Potassium not found");
    uint256 soil1Nutrients = Nutrients.get(simStore, worldAddress, soilObjectEntityId);
    // Initially no energy, so no nutrients
    assertTrue(soil1Nutrients == 0, "Soil nutrients not 0");

    vm.roll(block.number + 1);

    Energy.set(simStore, worldAddress, soilObjectEntityId, 150);
    world.activate(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord);
    soil1Nutrients = Nutrients.get(simStore, worldAddress, soilObjectEntityId);
    assertTrue(soil1Nutrients > 0, "Soil nutrients not > 0");

    vm.roll(block.number + 1);

    // Place down another soil beside it
    VoxelCoord memory soilCoord2 = VoxelCoord({ x: soilCoord.x, y: soilCoord.y, z: soilCoord.z + 1 });
    bytes32 soil2EntityId = world.build(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord2);
    bytes32 soil2ObjectEntityId = ObjectEntity.get(store, soil2EntityId);
    assertTrue(Nitrogen.get(simStore, worldAddress, soil2ObjectEntityId) > 0, "Nitrogen not found for soil 2");
    assertTrue(Phosphorus.get(simStore, worldAddress, soil2ObjectEntityId) > 0, "Phosphorus not found for soil 2");
    assertTrue(Potassium.get(simStore, worldAddress, soil2ObjectEntityId) > 0, "Potassium not found for soil 2");

    uint256 soil2Nutrients = Nutrients.get(simStore, worldAddress, soil2ObjectEntityId);

    // Concentrative soil should not have transferred nutrients to soil 2
    assertTrue(soil2Nutrients == 0, "Soil 2 nutrients not 0");

    uint256 soil2BeforeNutrients = soil1Nutrients + 10;
    Nutrients.set(simStore, worldAddress, soil2ObjectEntityId, soil2BeforeNutrients);

    vm.roll(block.number + 1);

    world.activate(agentObjectEntityId, ConcentrativeSoilObjectID, soilCoord2);
    // Concentrative soil should have transferred nutrients to soil 2
    assertTrue(
      Nutrients.get(simStore, worldAddress, soil2ObjectEntityId) > soil2BeforeNutrients,
      "Soil 2 nutrients not > soil 2 before nutrients"
    );
    assertTrue(
      Nutrients.get(simStore, worldAddress, soilObjectEntityId) < soil1Nutrients,
      "Soil nutrients not < soil 1 nutrients"
    );

    vm.stopPrank();
  }
}
