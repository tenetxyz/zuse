// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelType, OwnedBy } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, Mind, ObjectType } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { FaucetVoxelID, GrassVoxelID, AirVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { MindRegistry } from "@tenet-registry/src/codegen/tables/MindRegistry.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { SoilVoxelID, PlantVoxelID, FirePokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { NUM_BLOCKS_BEFORE_REDUCE_VELOCITY } from "@tenet-simulator/src/Constants.sol";
import { NUM_BLOCKS_FAINTED } from "@tenet-pokemon-extension/src/Constants.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Object } from "@tenet-simulator/src/codegen/tables/Object.sol";

contract PokemonTest is MudTest {
  IWorld private world;
  IStore private store;
  VoxelCoord private agentCoord;
  VoxelCoord private pokemon1Coord;
  VoxelCoord private pokemon2Coord;

  address payable internal alice;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    agentCoord = VoxelCoord(51, 10, 50);
  }

  function setupAgent() internal returns (VoxelEntity memory) {
    // Claim agent
    VoxelEntity memory faucetEntity = VoxelEntity({ scale: 1, entityId: getEntityAtCoord(1, VoxelCoord(50, 10, 50)) });
    VoxelEntity memory agentEntity = world.claimAgentFromFaucet(faucetEntity, FaucetVoxelID, agentCoord);
    return agentEntity;
  }

  function testFight() public {
    vm.startPrank(alice, alice);
    VoxelEntity memory agentEntity = setupAgent();

    // Get pokemon mind selector
    bytes4 mindSelector;
    {
      bytes memory mindData = MindRegistry.get(IStore(REGISTRY_ADDRESS), FirePokemonVoxelID, address(0));
      Mind[] memory minds = abi.decode(mindData, (Mind[]));
      assertTrue(minds.length == 1);
      mindSelector = minds[0].mindSelector;
    }

    // Place pokemon beside flower
    pokemon1Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z + 1 });
    VoxelEntity memory pokemon1Entity = world.buildWithAgent(
      FirePokemonVoxelID,
      pokemon1Coord,
      agentEntity,
      mindSelector
    );
    assertTrue(
      Object.get(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon1Entity.scale, pokemon1Entity.entityId) ==
        ObjectType.Fire
    );
    world.claimAgent(pokemon1Entity);
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon1Entity.scale, pokemon1Entity.entityId, 100);
    Health.set(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon1Entity.scale, pokemon1Entity.entityId, 200);
    Stamina.set(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon1Entity.scale, pokemon1Entity.entityId, 150);

    // Activate pokemon
    bytes32 pokemon1CAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon1Entity.entityId);

    pokemon2Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z - 1 });
    VoxelEntity memory pokemon2Entity = world.buildWithAgent(
      FirePokemonVoxelID,
      pokemon2Coord,
      agentEntity,
      mindSelector
    );
    assertTrue(
      Object.get(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon2Entity.scale, pokemon2Entity.entityId) ==
        ObjectType.Fire
    );
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon2Entity.scale, pokemon2Entity.entityId, 100);
    Health.set(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon2Entity.scale, pokemon2Entity.entityId, 200);
    Stamina.set(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon2Entity.scale, pokemon2Entity.entityId, 150);

    // Activate pokemon
    bytes32 pokemon2CAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon2Entity.entityId);

    // move pokemon1 beside pokemon2
    {
      VoxelCoord memory newPokemon1Coord = VoxelCoord({
        x: pokemon1Coord.x,
        y: pokemon1Coord.y,
        z: pokemon1Coord.z - 1
      });
      vm.roll(block.number + 1);
      (, pokemon1Entity) = world.moveWithAgent(FirePokemonVoxelID, pokemon1Coord, newPokemon1Coord, pokemon1Entity);
      vm.roll(block.number + NUM_BLOCKS_BEFORE_REDUCE_VELOCITY + 1);
      console.log("commence fight");
      // world.activateWithAgent(FirePokemonVoxelID, newPokemon1Coord, agentEntity, bytes4(0));
      console.logUint(
        Health.get(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon1Entity.scale, pokemon1Entity.entityId)
      );
      console.logUint(
        Health.get(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon2Entity.scale, pokemon2Entity.entityId)
      );
      assertTrue(
        Health.get(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon1Entity.scale, pokemon1Entity.entityId) == 0
      );
      assertTrue(
        Health.get(IStore(SIMULATOR_ADDRESS), worldAddress, pokemon2Entity.scale, pokemon2Entity.entityId) == 0
      );
      PokemonData memory pokemon1Data = Pokemon.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon1CAEntity);
      assertTrue(pokemon1Data.lastFaintedBlock > 0);
      assertTrue(pokemon1Data.fightingCAEntity == bytes32(0));
      assertTrue(pokemon1Data.isFainted == true);
      PokemonData memory pokemon2Data = Pokemon.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon2CAEntity);
      assertTrue(pokemon2Data.lastFaintedBlock > 0);
      assertTrue(pokemon2Data.fightingCAEntity == bytes32(0));
      assertTrue(pokemon2Data.isFainted == true);
      // Roll forward NUM_BLOCKS_FAINTED and assert that they can now fight again
      vm.roll(block.number + NUM_BLOCKS_FAINTED + 1);
      world.activateWithAgent(FirePokemonVoxelID, newPokemon1Coord, agentEntity, bytes4(0));
      pokemon1Data = Pokemon.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon1CAEntity);
      assertTrue(pokemon1Data.isFainted == false);
      pokemon2Data = Pokemon.get(IStore(BASE_CA_ADDRESS), worldAddress, pokemon2CAEntity);
      assertTrue(pokemon2Data.isFainted == false);
    }

    vm.stopPrank();
  }
}
