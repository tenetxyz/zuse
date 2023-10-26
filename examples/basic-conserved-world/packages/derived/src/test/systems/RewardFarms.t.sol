// // SPDX-License-Identifier: GPL-3.0
// pragma solidity >=0.8.0;

// import "forge-std/Test.sol";
// import { MudTest } from "@latticexyz/store/src/MudTest.sol";
// import { IStore } from "@latticexyz/store/src/IStore.sol";
// import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
// import { VoxelType, OwnedBy } from "@tenet-world/src/codegen/Tables.sol";
// import { VoxelCoord, VoxelTypeData, VoxelEntity, Mind, ObjectType } from "@tenet-utils/src/Types.sol";
// import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
// import { FaucetVoxelID, GrassVoxelID, AirVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
// import { MindRegistry } from "@tenet-registry/src/codegen/tables/MindRegistry.sol";
// import { REGISTRY_ADDRESS, BASE_CA_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
// import { ProteinSoilVoxelID, PlantVoxelID, FirePokemonVoxelID, GrassPokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
// import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
// import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
// import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
// import { console } from "forge-std/console.sol";
// import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
// import { NUM_BLOCKS_BEFORE_REDUCE_VELOCITY } from "@tenet-simulator/src/Constants.sol";
// import { NUM_BLOCKS_FAINTED } from "@tenet-pokemon-extension/src/Constants.sol";
// import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
// import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
// import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
// import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
// import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
// import { Object } from "@tenet-simulator/src/codegen/tables/Object.sol";

// contract RewardFarmsTest is MudTest {
//   IWorld private world;
//   IStore private store;
//   VoxelCoord private agentCoord;
//   VoxelCoord private pokemon1Coord;
//   VoxelCoord private pokemon2Coord;

//   address payable internal alice;

//   function setUp() public override {
//     super.setUp();
//     world = IWorld(worldAddress);
//     store = IStore(worldAddress);
//     alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
//     agentCoord = VoxelCoord(51, 10, 50);
//   }

//   function setupAgent() internal returns (VoxelEntity memory) {
//     // Claim agent
//     VoxelEntity memory faucetEntity = VoxelEntity({ scale: 1, entityId: getEntityAtCoord(1, VoxelCoord(50, 10, 50)) });
//     VoxelEntity memory agentEntity = world.claimAgentFromFaucet(faucetEntity, FaucetVoxelID, agentCoord);
//     Health.set(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId, 500);
//     return agentEntity;
//   }

//   function testRewardFarm() public {
//     vm.startPrank(alice, alice);
//     VoxelEntity memory agentEntity = setupAgent();

//     vm.stopPrank();
//   }
// }
