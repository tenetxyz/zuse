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

contract MineTest is MudTest {
  IWorld private world;
  IStore private store;

  address payable internal alice;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    alice = payable(address(0x1));
  }

  function testClaimAgent() public {
    vm.startPrank(alice);
    // Claim agent
    VoxelEntity memory agentEntity = VoxelEntity({ scale: 1, entityId: getEntityAtCoord(1, VoxelCoord(10, 2, 10)) });
    world.claimAgent(agentEntity);

    // VoxelCoord memory highEnergyCoord = VoxelCoord(10, 2, 11);
    // // Mine block with high energy
    // world.mineWithAgent(GrassVoxelID, highEnergyCoord, agentEntity);

    // // Place down energy source
    // world.buildWithAgent(EnergySourceVoxelID, highEnergyCoord, agentEntity, bytes4(0));
    // // Place down soil beside it
    // VoxelEntity memory soilEntity = world.buildWithAgent(SoilVoxelID, VoxelCoord(9, 2, 11), agentEntity, bytes4(0));
    // // Place down plant on top of soil
    // VoxelEntity memory plantEntity = world.buildWithAgent(PlantVoxelID, VoxelCoord(9, 3, 11), agentEntity, bytes4(0));
    // bytes32 plantCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, plantEntity.entityId);
    // PlantData memory plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    // assertTrue(plantData.stage == PlantStage.Seed);

    // // Pass blocks then activate energy source, and transform to sprout
    // vm.roll(block.number + ENERGY_SOURCE_WAIT_BLOCKS + 1);
    // world.activateWithAgent(EnergySourceVoxelID, highEnergyCoord, agentEntity, bytes4(0));
    // plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    // assertTrue(plantData.stage == PlantStage.Sprout);

    // // Pass blocks then activate energy source, and transform to flower
    // vm.roll(block.number + ENERGY_SOURCE_WAIT_BLOCKS + 1);
    // world.activateWithAgent(EnergySourceVoxelID, highEnergyCoord, agentEntity, bytes4(0));
    // plantData = Plant.get(IStore(BASE_CA_ADDRESS), worldAddress, plantCAEntity);
    // assertTrue(plantData.stage == PlantStage.Flower);

    // // Get pokemon mind selector
    // bytes memory mindData = MindRegistry.get(IStore(REGISTRY_ADDRESS), PokemonVoxelID, address(0));
    // Mind[] memory minds = abi.decode(mindData, (Mind[]));
    // assertTrue(minds.length == 1);
    // bytes4 mindSelector = minds[0].mindSelector;

    // // Place pokemon beside flower
    // VoxelEntity memory pokemonEntity = world.buildWithAgent(
    //   PokemonVoxelID,
    //   VoxelCoord(10, 3, 11),
    //   agentEntity,
    //   mindSelector
    // );
    // // Activate energy source
    // vm.roll(block.number + ENERGY_SOURCE_WAIT_BLOCKS + 1);
    // world.activateWithAgent(EnergySourceVoxelID, highEnergyCoord, agentEntity, bytes4(0));
    // bytes32 pokemonCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemonEntity.entityId);
    // console.log("pokemonCAEntity");
    // console.logBytes32(pokemonCAEntity);
    // PokemonData memory pokemonData = Pokemon.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemonCAEntity);
    // uint256 pokemonEnergy = BodyPhysics.getEnergy(pokemonEntity.scale, pokemonEntity.entityId);
    // console.log("pokemonData");
    // console.logUint(pokemonData.lastEnergy);
    // console.logUint(pokemonEnergy);
    // assertTrue(pokemonData.lastEnergy > 0);

    vm.stopPrank();
  }
}
