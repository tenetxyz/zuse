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
import { ConcentrativeSoilVoxelID, PlantVoxelID, FirePokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { AMOUNT_REQUIRED_FOR_SPROUT, AMOUNT_REQUIRED_FOR_FLOWER } from "@tenet-pokemon-extension/src/systems/voxel-interactions/PlantSystem.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Nutrients } from "@tenet-simulator/src/codegen/tables/Nutrients.sol";
import { Elixir } from "@tenet-simulator/src/codegen/tables/Elixir.sol";
import { Protein } from "@tenet-simulator/src/codegen/tables/Protein.sol";
import { Nitrogen } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorous } from "@tenet-simulator/src/codegen/tables/Phosphorous.sol";
import { Potassium } from "@tenet-simulator/src/codegen/tables/Potassium.sol";

contract MoveTest is MudTest {
  IWorld private world;
  IStore private store;
  VoxelCoord private energySourceCoord;
  VoxelCoord private agentCoord;

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
    Health.set(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId, 500);
    return agentEntity;
  }

  function testMoveYourself() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );

    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    (, agentEntity) = world.moveWithAgent(FaucetVoxelID, agentCoord, newAgentCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    assertTrue(staminaBefore > staminaAfter);

    vm.stopPrank();
  }

  function testMoveBlock() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory soilCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory soilEntity = world.buildWithAgent(ConcentrativeSoilVoxelID, soilCoord, agentEntity, bytes4(0));
    Energy.set(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId, 150);
    world.activateWithAgent(ConcentrativeSoilVoxelID, soilCoord, agentEntity, bytes4(0));
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

    // Place down plant on top of it
    vm.roll(block.number + 1);
    VoxelCoord memory newSoilCoord = VoxelCoord({ x: soilCoord.x + 1, y: soilCoord.y, z: soilCoord.z });
    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    (, soilEntity) = world.moveWithAgent(ConcentrativeSoilVoxelID, soilCoord, newSoilCoord, agentEntity);
    assertTrue(
      soil1Nutrients == Nutrients.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId)
    );
    assertTrue(Nitrogen.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
    assertTrue(Phosphorous.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
    assertTrue(Potassium.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);

    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    assertTrue(staminaBefore > staminaAfter);

    vm.stopPrank();
  }

  function testMoveAgent() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory faucetCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory faucetEntity = world.buildWithAgent(FaucetVoxelID, faucetCoord, agentEntity, bytes4(0));
    Stamina.set(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId, 100);

    vm.roll(block.number + 1);
    VoxelCoord memory newfaucetCoord = VoxelCoord({ x: faucetCoord.x, y: faucetCoord.y + 1, z: faucetCoord.z });
    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    (, faucetEntity) = world.moveWithAgent(FaucetVoxelID, faucetCoord, newfaucetCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    assertTrue(staminaBefore > staminaAfter);
    assertTrue(Stamina.get(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId) == 100);

    vm.stopPrank();
  }
}
