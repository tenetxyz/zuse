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
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { EnergySourceVoxelID, SoilVoxelID, PlantVoxelID, PokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";

import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";

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

    // Mine block with high energy
    // uint256 beforeEnergy = BodyPhysics.getEnergy(agentEntity.scale, agentEntity.entityId);
    // world.mineWithAgent(GrassVoxelID, VoxelCoord(10, 2, 11), agentEntity);
    // uint256 afterEnergy = BodyPhysics.getEnergy(agentEntity.scale, agentEntity.entityId);
    // assertTrue(afterEnergy > beforeEnergy);
    bytes memory mindData = MindRegistry.get(IStore(REGISTRY_ADDRESS), PokemonVoxelID, address(0));
    Mind[] memory minds = abi.decode(mindData, (Mind[]));
    assertTrue(minds.length == 1);
    bytes4 mindSelector = minds[0].mindSelector;

    // Get pokemon mind selector
    world.buildWithAgent(PokemonVoxelID, VoxelCoord(10, 2, 11), agentEntity, mindSelector);

    vm.stopPrank();
  }
}
