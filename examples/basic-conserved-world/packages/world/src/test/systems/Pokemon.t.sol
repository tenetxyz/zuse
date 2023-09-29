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
import { NUM_BLOCKS_BEFORE_REDUCE } from "@tenet-world/src/systems/VelocitySystem.sol";

contract PokemonTest is MudTest {
  IWorld private world;
  IStore private store;
  VoxelCoord private agentCoord;

  address payable internal alice;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    agentCoord = VoxelCoord(10, 2, 10);
  }

  function setupAgent() internal returns (VoxelEntity memory) {
    // Claim agent
    VoxelEntity memory agentEntity = VoxelEntity({ scale: 1, entityId: getEntityAtCoord(1, agentCoord) });
    world.claimAgent(agentEntity);

    return agentEntity;
  }

  function testFight() public {
    vm.startPrank(alice);
    VoxelEntity memory agentEntity = setupAgent();

    {
      VoxelCoord memory flower1Coord = VoxelCoord({ x: agentCoord.x, y: agentCoord.y, z: agentCoord.z + 1 });
      VoxelEntity memory flower1Entity = world.buildWithAgent(PlantVoxelID, flower1Coord, agentEntity, bytes4(0));
      BodyPhysics.setEnergy(flower1Entity.scale, flower1Entity.entityId, 500);
      vm.roll(block.number + 1);
      world.activateWithAgent(PlantVoxelID, flower1Coord, agentEntity, bytes4(0));
      bytes32 plant1CAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, flower1Entity.entityId);
      PlantData memory plant1Data = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plant1CAEntity);
      assertTrue(plant1Data.stage == PlantStage.Flower);
    }

    // Get pokemon mind selector
    bytes4 mindSelector;
    {
      bytes memory mindData = MindRegistry.get(IStore(REGISTRY_ADDRESS), PokemonVoxelID, address(0));
      Mind[] memory minds = abi.decode(mindData, (Mind[]));
      assertTrue(minds.length == 1);
      mindSelector = minds[0].mindSelector;
    }

    // Place pokemon beside flower
    VoxelCoord memory pokemon1Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z + 1 });
    VoxelEntity memory pokemon1Entity = world.buildWithAgent(PokemonVoxelID, pokemon1Coord, agentEntity, mindSelector);
    world.claimAgent(pokemon1Entity);
    BodyPhysics.setEnergy(pokemon1Entity.scale, pokemon1Entity.entityId, 500);
    assertTrue(BodyPhysics.getEnergy(pokemon1Entity.scale, pokemon1Entity.entityId) == 500);
    // Activate pokemon
    vm.roll(block.number + 1);
    world.activateWithAgent(PokemonVoxelID, pokemon1Coord, agentEntity, bytes4(0));
    bytes32 pokemon1CAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon1Entity.entityId);
    PokemonData memory pokemon1Data = Pokemon.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon1CAEntity);
    assertTrue(pokemon1Data.health == 200);
    assertTrue(pokemon1Data.stamina == 150);

    {
      VoxelCoord memory flower2Coord = VoxelCoord({ x: agentCoord.x, y: agentCoord.y, z: agentCoord.z - 1 });
      VoxelEntity memory flower2Entity = world.buildWithAgent(PlantVoxelID, flower2Coord, agentEntity, bytes4(0));
      BodyPhysics.setEnergy(flower2Entity.scale, flower2Entity.entityId, 500);
      vm.roll(block.number + 1);
      world.activateWithAgent(PlantVoxelID, flower2Coord, agentEntity, bytes4(0));
      bytes32 plant2CAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, flower2Entity.entityId);
      PlantData memory plant2Data = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plant2CAEntity);
      assertTrue(plant2Data.stage == PlantStage.Flower);
    }

    VoxelCoord memory pokemon2Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z - 1 });
    VoxelEntity memory pokemon2Entity = world.buildWithAgent(PokemonVoxelID, pokemon2Coord, agentEntity, mindSelector);
    BodyPhysics.setEnergy(pokemon2Entity.scale, pokemon2Entity.entityId, 500);
    assertTrue(BodyPhysics.getEnergy(pokemon2Entity.scale, pokemon2Entity.entityId) == 500);
    // Activate pokemon
    vm.roll(block.number + 1);
    world.activateWithAgent(PokemonVoxelID, pokemon2Coord, agentEntity, bytes4(0));
    bytes32 pokemon2CAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon2Entity.entityId);
    PokemonData memory pokemon2Data = Pokemon.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon2CAEntity);
    assertTrue(pokemon2Data.health == 200);
    assertTrue(pokemon2Data.stamina == 150);

    // Mine both flowers
    {
      vm.roll(block.number + 1);
      world.mineWithAgent(
        PlantVoxelID,
        VoxelCoord({ x: agentCoord.x, y: agentCoord.y, z: agentCoord.z - 1 }),
        agentEntity
      );
      world.mineWithAgent(
        PlantVoxelID,
        VoxelCoord({ x: agentCoord.x, y: agentCoord.y, z: agentCoord.z + 1 }),
        agentEntity
      );
      pokemon1Data = Pokemon.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon1CAEntity);
      assertTrue(pokemon1Data.health == 200);
      assertTrue(pokemon1Data.stamina == 150);
      pokemon2Data = Pokemon.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon2CAEntity);
      assertTrue(pokemon2Data.health == 200);
      assertTrue(pokemon2Data.stamina == 150);
    }

    // move pokemon1 beside pokemon2
    {
      VoxelCoord memory newPokemon1Coord = VoxelCoord({
        x: pokemon1Coord.x,
        y: pokemon1Coord.y,
        z: pokemon1Coord.z - 1
      });
      vm.roll(block.number + 1);
      console.log("moving pokemon");
      (, pokemon1Entity) = world.moveWithAgent(PokemonVoxelID, pokemon1Coord, newPokemon1Coord, pokemon1Entity);
      vm.roll(block.number + NUM_BLOCKS_BEFORE_REDUCE + 1);
      console.log("activate commence fight");
      // BodyPhysics.setVelocity(pokemon1Entity.scale, pokemon1Entity.entityId, abi.encode(VoxelCoord(0, 0, 0)));
      world.activateWithAgent(PokemonVoxelID, newPokemon1Coord, agentEntity, bytes4(0));
    }

    vm.stopPrank();
  }
}
