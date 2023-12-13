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
import { ObjectType } from "@tenet-world/src/codegen/tables/ObjectType.sol";
import { OwnedBy } from "@tenet-world/src/codegen/tables/OwnedBy.sol";
import { ObjectEntity } from "@tenet-world/src/codegen/tables/ObjectEntity.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { SIMULATOR_ADDRESS, BuilderObjectID, GrassObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";
import { WORLD_ADDRESS, SOIL_MASS, FarmerObjectID, PlantObjectID, ConcentrativeSoilObjectID, DiffusiveSoilObjectID, ProteinSoilObjectID, ElixirSoilObjectID } from "@tenet-farming/src/Constants.sol";
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
import { Plant, PlantData } from "@tenet-farming/src/codegen/tables/Plant.sol";
import { Farmer } from "@tenet-farming/src/codegen/tables/Farmer.sol";
import { PlantConsumer } from "@tenet-farming/src/Types.sol";

// TODO: Replace relative imports in IWorld.sol, instead of this hack
interface IWorld is IBaseWorld, IBuildSystem, IMineSystem, IMoveSystem, IActivateSystem, IFaucetSystem {

}

contract FarmerTest is MudTest {
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

    bytes32 agentObjectTypeId = FarmerObjectID;
    bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, agentObjectTypeId, agentCoord);
    assertTrue(uint256(agentEntityId) != 0, "Agent not found at coord");
    bytes32 agentObjectEntityId = ObjectEntity.get(store, agentEntityId);

    return (agentEntityId, agentObjectEntityId);
  }

  function testFarmer() public {
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

    Energy.set(simStore, worldAddress, soilObjectEntityId, 300);
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

    {
      PlantData memory plantData = Plant.get(store, worldAddress, plantObjectEntityId);
      PlantConsumer[] memory consumers = abi.decode(plantData.consumers, (PlantConsumer[]));
      assertTrue(consumers.length == 0, "Consumers not empty");
      assertTrue(plantData.totalProduced > 0, "Produced not > 0");
    }

    // Place farmer next to flower
    VoxelCoord memory farmerCoord = VoxelCoord({ x: plantCoord.x, y: plantCoord.y, z: plantCoord.z - 1 });
    uint256 healthBefore = Health.getHealth(simStore, worldAddress, agentObjectEntityId);
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(agentObjectEntityId, FarmerObjectID, agentCoord, farmerCoord);

    // Since farmer is not set to hungry, it should not eat the plant
    assertTrue(Health.getHealth(simStore, worldAddress, agentObjectEntityId) == healthBefore, "Health increased");
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) <= staminaBefore, "Stamina increased");

    // Plant should lose all protein and elixir
    assertTrue(Elixir.get(simStore, worldAddress, plantObjectEntityId) > 0, "Elixir not found for plant");
    assertTrue(Protein.get(simStore, worldAddress, plantObjectEntityId) > 0, "Protein not found for plant");

    {
      PlantData memory plantData = Plant.get(store, worldAddress, plantObjectEntityId);
      PlantConsumer[] memory consumers = abi.decode(plantData.consumers, (PlantConsumer[]));
      assertTrue(consumers.length == 0, "Consumers not empty");
    }
    healthBefore = Health.getHealth(simStore, worldAddress, agentObjectEntityId);
    staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);

    // Set farmer to hungry
    // Note: This is a hack, since the namespace owner is not the same as the world owner
    vm.startPrank(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC, 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
    Farmer.setIsHungry(store, worldAddress, agentObjectEntityId, true);
    vm.stopPrank();
    vm.startPrank(alice, alice);
    world.activate(agentObjectEntityId, PlantObjectID, plantCoord);

    // Farmer should have eaten the plant
    assertTrue(Health.getHealth(simStore, worldAddress, agentObjectEntityId) > healthBefore, "Health not increased");
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) > staminaBefore, "Stamina not increased");

    // Plant should lose all protein and elixir
    assertTrue(Elixir.get(simStore, worldAddress, plantObjectEntityId) == 0, "Elixir found for plant");
    assertTrue(Protein.get(simStore, worldAddress, plantObjectEntityId) == 0, "Protein found for plant");

    {
      PlantData memory plantData = Plant.get(store, worldAddress, plantObjectEntityId);
      PlantConsumer[] memory consumers = abi.decode(plantData.consumers, (PlantConsumer[]));
      assertTrue(consumers.length == 1, "Consumers not empty");
      assertTrue(consumers[0].objectEntityId == agentObjectEntityId, "Consumer not agent");
      assertTrue(consumers[0].consumedBlockNumber == block.number, "Consumed block number not correct");
    }

    vm.stopPrank();
  }
}
