// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelType, OwnedBy } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, Mind } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { FaucetVoxelID, GrassVoxelID, AirVoxelID, DirtVoxelID, BedrockVoxelID, BuilderVoxelID } from "@tenet-level1-ca/src/Constants.sol";
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
  address payable internal bob;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    bob = payable(address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8));
    agentCoord = VoxelCoord(51, 10, 50);
  }

  function setupAgent() internal returns (VoxelEntity memory) {
    // Claim agent
    VoxelEntity memory faucetEntity = VoxelEntity({ scale: 1, entityId: getEntityAtCoord(1, VoxelCoord(50, 10, 50)) });
    VoxelEntity memory agentEntity = world.claimAgentFromFaucet(faucetEntity, FaucetVoxelID, agentCoord);
    Health.setHealth(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId, 500);
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

  function testSimpleCollision() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory smallMassEntity;
    VoxelCoord memory smallMassCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      smallMassCoord = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z });
      uint256 initMass = 1;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });
      smallMassEntity = world.spawnBody(
        voxelTypeId,
        smallMassCoord,
        bytes4(0),
        initMass,
        initEnergy,
        initVelocity,
        0,
        0
      );
    }

    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );

    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    console.log("moving");
    console.logBytes32(agentEntity.entityId);
    bytes32 agentCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, agentEntity.entityId);
    address agentOwner = OwnedBy.get(agentEntity.scale, agentEntity.entityId);
    (, agentEntity) = world.moveWithAgent(FaucetVoxelID, agentCoord, newAgentCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    console.log("staminaAfter");
    console.logUint(staminaAfter);
    assertTrue(staminaBefore > staminaAfter);
    assertTrue(CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, agentEntity.entityId) == agentCAEntity);
    assertTrue(OwnedBy.get(agentEntity.scale, agentEntity.entityId) == agentOwner);

    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity agent");
    console.logInt(agentVelocity.x);
    assertTrue(agentVelocity.x == 1);
    assertTrue(agentVelocity.y == 0);
    assertTrue(agentVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId) > 0);

    smallMassEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(smallMassCoord.x + 1, smallMassCoord.y, smallMassCoord.z))
    });
    VoxelCoord memory smallMassVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity.scale, smallMassEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity small mass");
    console.logInt(smallMassVelocity.x);
    assertTrue(smallMassVelocity.x == 1);
    assertTrue(smallMassVelocity.y == 0);
    assertTrue(smallMassVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity.scale, smallMassEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testCollisionBounceBack() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory massEntity;
    VoxelCoord memory massCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      massCoord = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z });
      uint256 initMass = 5;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });
      massEntity = world.spawnBody(voxelTypeId, massCoord, bytes4(0), initMass, initEnergy, initVelocity, 0, 0);
    }

    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );

    Velocity.setVelocity(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId,
      abi.encode(VoxelCoord({ x: 4, y: 0, z: 0 }))
    );
    bytes32 agentCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, agentEntity.entityId);
    address agentOwner = OwnedBy.get(agentEntity.scale, agentEntity.entityId);
    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    console.log("moving");
    console.logBytes32(agentCAEntity);
    (, agentEntity) = world.moveWithAgent(FaucetVoxelID, agentCoord, newAgentCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    console.log("post move");
    console.logBytes32(agentEntity.entityId);
    assertTrue(staminaBefore > staminaAfter);
    assertTrue(CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, agentEntity.entityId) == agentCAEntity);
    assertTrue(OwnedBy.get(agentEntity.scale, agentEntity.entityId) == agentOwner);

    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity agent");
    console.logInt(agentVelocity.x);
    assertTrue(agentVelocity.x == 4);
    assertTrue(agentVelocity.y == 0);
    assertTrue(agentVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId) > 0);

    massEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(massCoord.x + 1, massCoord.y, massCoord.z))
    });
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, massEntity.scale, massEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity mass");
    console.logInt(massVelocity.x);
    assertTrue(massVelocity.x == 1);
    assertTrue(massVelocity.y == 0);
    assertTrue(massVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, massEntity.scale, massEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testCollisionMultipleBlocksPushed() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory massEntity;
    VoxelCoord memory massCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      massCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z - 1 });
      uint256 initMass = 5;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 10 });
      massEntity = world.spawnBody(voxelTypeId, massCoord, bytes4(0), initMass, initEnergy, initVelocity, 0, 0);
    }

    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );

    Velocity.setVelocity(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId,
      abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }))
    );
    bytes32 agentCAEntity = CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, agentEntity.entityId);
    address agentOwner = OwnedBy.get(agentEntity.scale, agentEntity.entityId);
    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    console.log("moving");
    console.logBytes32(agentCAEntity);
    (, agentEntity) = world.moveWithAgent(FaucetVoxelID, agentCoord, newAgentCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    console.log("post move");
    console.logBytes32(agentEntity.entityId);
    assertTrue(staminaBefore > staminaAfter);
    assertTrue(CAEntityMapping.get(IStore(BASE_CA_ADDRESS), worldAddress, agentEntity.entityId) == agentCAEntity);
    assertTrue(OwnedBy.get(agentEntity.scale, agentEntity.entityId) == agentOwner);

    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity agent");
    assertTrue(agentVelocity.x == 1);
    assertTrue(agentVelocity.y == 0);
    assertTrue(agentVelocity.z == 2);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId) > 0);

    massEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(massCoord.x, massCoord.y, massCoord.z - 2))
    });
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, massEntity.scale, massEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity mass");
    assertTrue(massVelocity.x == 0);
    assertTrue(massVelocity.y == 0);
    assertTrue(massVelocity.z == 8);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, massEntity.scale, massEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testCollisionMoveTwo() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory smallMassEntity1;
    VoxelCoord memory smallMassCoord1;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      smallMassCoord1 = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z });
      uint256 initMass = 1;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });
      smallMassEntity1 = world.spawnBody(
        voxelTypeId,
        smallMassCoord1,
        bytes4(0),
        initMass,
        initEnergy,
        initVelocity,
        0,
        0
      );
    }

    VoxelEntity memory smallMassEntity2;
    VoxelCoord memory smallMassCoord2;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      smallMassCoord2 = VoxelCoord({ x: agentCoord.x + 3, y: agentCoord.y, z: agentCoord.z });
      uint256 initMass = 1;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });
      smallMassEntity2 = world.spawnBody(
        voxelTypeId,
        smallMassCoord2,
        bytes4(0),
        initMass,
        initEnergy,
        initVelocity,
        0,
        0
      );
    }

    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );

    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    console.log("moving");
    console.logBytes32(agentEntity.entityId);
    (, agentEntity) = world.moveWithAgent(FaucetVoxelID, agentCoord, newAgentCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    console.log("staminaAfter");
    console.logUint(staminaAfter);
    assertTrue(staminaBefore > staminaAfter);

    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity agent");
    console.logInt(agentVelocity.x);
    assertTrue(agentVelocity.x == 1);
    assertTrue(agentVelocity.y == 0);
    assertTrue(agentVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId) > 0);

    smallMassEntity1 = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(smallMassCoord1.x + 1, smallMassCoord1.y, smallMassCoord1.z))
    });
    VoxelCoord memory smallMass1Velocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity1.scale, smallMassEntity1.entityId),
      (VoxelCoord)
    );
    console.log("velocity small mass 1");
    console.logInt(smallMass1Velocity.x);
    assertTrue(smallMass1Velocity.x == 1);
    assertTrue(smallMass1Velocity.y == 0);
    assertTrue(smallMass1Velocity.z == 0);
    assertTrue(
      Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity1.scale, smallMassEntity1.entityId) > 0
    );

    smallMassEntity2 = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(smallMassCoord2.x + 1, smallMassCoord2.y, smallMassCoord2.z))
    });
    VoxelCoord memory smallMass2Velocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity2.scale, smallMassEntity2.entityId),
      (VoxelCoord)
    );
    console.log("velocity small mass 2");
    console.logInt(smallMass1Velocity.x);
    assertTrue(smallMass2Velocity.x == 1);
    assertTrue(smallMass2Velocity.y == 0);
    assertTrue(smallMass2Velocity.z == 0);
    assertTrue(
      Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity2.scale, smallMassEntity2.entityId) > 0
    );

    vm.stopPrank();
  }

  function testCollisionNoVelocityChange() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory smallMassEntity;
    VoxelCoord memory smallMassCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      smallMassCoord = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z });
      uint256 initMass = 1;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: 1, y: 0, z: 0 });
      smallMassEntity = world.spawnBody(
        voxelTypeId,
        smallMassCoord,
        bytes4(0),
        initMass,
        initEnergy,
        initVelocity,
        0,
        0
      );
    }

    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );

    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    console.log("moving");
    console.logBytes32(agentEntity.entityId);
    (, agentEntity) = world.moveWithAgent(FaucetVoxelID, agentCoord, newAgentCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    console.log("staminaAfter");
    console.logUint(staminaAfter);
    assertTrue(staminaBefore > staminaAfter);

    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity agent");
    console.logInt(agentVelocity.x);
    assertTrue(agentVelocity.x == 1);
    assertTrue(agentVelocity.y == 0);
    assertTrue(agentVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId) > 0);

    smallMassEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(smallMassCoord.x, smallMassCoord.y, smallMassCoord.z))
    });
    VoxelCoord memory smallMassVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity.scale, smallMassEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity small mass");
    console.logInt(smallMassVelocity.x);
    assertTrue(smallMassVelocity.x == 1);
    assertTrue(smallMassVelocity.y == 0);
    assertTrue(smallMassVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity.scale, smallMassEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testCollisionSameDirection() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory smallMassEntity;
    VoxelCoord memory smallMassCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      smallMassCoord = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z });
      uint256 initMass = 1;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: 1, y: 0, z: 0 });
      smallMassEntity = world.spawnBody(
        voxelTypeId,
        smallMassCoord,
        bytes4(0),
        initMass,
        initEnergy,
        initVelocity,
        0,
        0
      );
    }

    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    Velocity.setVelocity(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId,
      abi.encode(VoxelCoord({ x: 4, y: 0, z: 0 }))
    );

    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    console.log("moving");
    console.logBytes32(agentEntity.entityId);
    (, agentEntity) = world.moveWithAgent(FaucetVoxelID, agentCoord, newAgentCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    console.log("staminaAfter");
    console.logUint(staminaAfter);
    assertTrue(staminaBefore > staminaAfter);

    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity agent");
    console.logInt(agentVelocity.x);
    assertTrue(agentVelocity.x == 5);
    assertTrue(agentVelocity.y == 0);
    assertTrue(agentVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId) > 0);

    smallMassEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(smallMassCoord.x + 4, smallMassCoord.y, smallMassCoord.z))
    });
    VoxelCoord memory smallMassVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity.scale, smallMassEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity small mass");
    console.logInt(smallMassVelocity.x);
    assertTrue(smallMassVelocity.x == 5);
    assertTrue(smallMassVelocity.y == 0);
    assertTrue(smallMassVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity.scale, smallMassEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testCollisionOppositeDirectionEqualVelocityDifferentMass() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory smallMassEntity;
    VoxelCoord memory smallMassCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      smallMassCoord = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z });
      uint256 initMass = 1;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: -1, y: 0, z: 0 });
      smallMassEntity = world.spawnBody(
        voxelTypeId,
        smallMassCoord,
        bytes4(0),
        initMass,
        initEnergy,
        initVelocity,
        0,
        0
      );
    }

    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );

    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    console.log("moving");
    console.logBytes32(agentEntity.entityId);
    (, agentEntity) = world.moveWithAgent(FaucetVoxelID, agentCoord, newAgentCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    console.log("staminaAfter");
    console.logUint(staminaAfter);
    assertTrue(staminaBefore > staminaAfter);

    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity agent");
    console.logInt(agentVelocity.x);
    assertTrue(agentVelocity.x == 1);
    assertTrue(agentVelocity.y == 0);
    assertTrue(agentVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId) > 0);

    smallMassEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(smallMassCoord.x + 2, smallMassCoord.y, smallMassCoord.z))
    });
    VoxelCoord memory smallMassVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity.scale, smallMassEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity small mass");
    console.logInt(smallMassVelocity.x);
    assertTrue(smallMassVelocity.x == 1);
    assertTrue(smallMassVelocity.y == 0);
    assertTrue(smallMassVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity.scale, smallMassEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testCollisionOppositeDirectionEqualVelocityEqualMass() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory smallMassEntity;
    VoxelCoord memory smallMassCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      smallMassCoord = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z });
      uint256 initMass = 10;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: -1, y: 0, z: 0 });
      smallMassEntity = world.spawnBody(
        voxelTypeId,
        smallMassCoord,
        bytes4(0),
        initMass,
        initEnergy,
        initVelocity,
        0,
        0
      );
    }

    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    Mass.set(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId, 10);

    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    console.log("moving");
    console.logBytes32(agentEntity.entityId);
    (, agentEntity) = world.moveWithAgent(FaucetVoxelID, agentCoord, newAgentCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    console.log("staminaAfter");
    console.logUint(staminaAfter);
    assertTrue(staminaBefore > staminaAfter);

    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity agent");
    console.logInt(agentVelocity.x);
    assertTrue(agentVelocity.x == 1);
    assertTrue(agentVelocity.y == 0);
    assertTrue(agentVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, agentEntity.scale, agentEntity.entityId) > 0);

    smallMassEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(smallMassCoord.x, smallMassCoord.y, smallMassCoord.z))
    });
    VoxelCoord memory smallMassVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity.scale, smallMassEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity small mass");
    console.logInt(smallMassVelocity.x);
    assertTrue(smallMassVelocity.x == -1);
    assertTrue(smallMassVelocity.y == 0);
    assertTrue(smallMassVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, smallMassEntity.scale, smallMassEntity.entityId) > 0);

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
    VoxelCoord memory soilVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId),
      (VoxelCoord)
    );
    assertTrue(soilVelocity.x == 1);
    assertTrue(soilVelocity.y == 0);
    assertTrue(soilVelocity.z == 0);
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

  function testMoveBlockBounceBack() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory smallMassEntity;
    VoxelCoord memory smallMassCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      smallMassCoord = VoxelCoord({ x: agentCoord.x + 3, y: agentCoord.y, z: agentCoord.z });
      uint256 initMass = 10;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: -4, y: 0, z: 0 });
      smallMassEntity = world.spawnBody(
        voxelTypeId,
        smallMassCoord,
        bytes4(0),
        initMass,
        initEnergy,
        initVelocity,
        0,
        0
      );
    }

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
    console.log("moveWithAgent block go");
    console.logBytes32(soilEntity.entityId);
    (, soilEntity) = world.moveWithAgent(ConcentrativeSoilVoxelID, soilCoord, newSoilCoord, agentEntity);
    console.log("post move entity");
    console.logBytes32(soilEntity.entityId);
    VoxelCoord memory soilVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId),
      (VoxelCoord)
    );
    assertTrue(getEntityAtCoord(1, VoxelCoord(soilCoord.x, soilCoord.y, soilCoord.z)) == soilEntity.entityId);
    assertTrue(
      VoxelType.getVoxelTypeId(1, getEntityAtCoord(1, VoxelCoord(newSoilCoord.x, newSoilCoord.y, newSoilCoord.z))) ==
        AirVoxelID
    );
    assertTrue(soilVelocity.x == 0);
    assertTrue(soilVelocity.y == 0);
    assertTrue(soilVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
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

  function testMoveBlockCollisionPushedMultiple() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory massEntity;
    VoxelCoord memory massCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      massCoord = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z - 1 });
      uint256 initMass = 5;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 10 });
      massEntity = world.spawnBody(voxelTypeId, massCoord, bytes4(0), initMass, initEnergy, initVelocity, 0, 0);
    }

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
    console.log("moveWithAgent block go");
    console.logBytes32(soilEntity.entityId);
    (, soilEntity) = world.moveWithAgent(ConcentrativeSoilVoxelID, soilCoord, newSoilCoord, agentEntity);
    console.log("post move entity");
    console.logBytes32(soilEntity.entityId);
    VoxelCoord memory soilVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId),
      (VoxelCoord)
    );
    assertTrue(soilVelocity.x == 1);
    assertTrue(soilVelocity.y == 0);
    assertTrue(soilVelocity.z == 2);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, soilEntity.scale, soilEntity.entityId) > 0);
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

    massEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(massCoord.x, massCoord.y, massCoord.z - 2))
    });
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, massEntity.scale, massEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity mass");
    assertTrue(massVelocity.x == 0);
    assertTrue(massVelocity.y == 0);
    assertTrue(massVelocity.z == 8);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, massEntity.scale, massEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testMoveAgent() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory faucetCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory faucetEntity = world.buildWithAgent(FaucetVoxelID, faucetCoord, agentEntity, bytes4(0));
    Stamina.set(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId, 100);
    vm.startPrank(bob, bob);
    world.claimAgent(faucetEntity);
    vm.stopPrank();
    vm.startPrank(alice, alice);

    vm.roll(block.number + 1);
    VoxelCoord memory newfaucetCoord = VoxelCoord({ x: faucetCoord.x, y: faucetCoord.y + 1, z: faucetCoord.z });
    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    address agentOwner = OwnedBy.get(faucetEntity.scale, faucetEntity.entityId);
    console.log("owner before");
    console.logAddress(agentOwner);
    (, faucetEntity) = world.moveWithAgent(FaucetVoxelID, faucetCoord, newfaucetCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    assertTrue(staminaBefore > staminaAfter);
    assertTrue(Stamina.get(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId) == 100);
    assertTrue(OwnedBy.get(faucetEntity.scale, faucetEntity.entityId) == agentOwner);
    VoxelCoord memory faucetVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId),
      (VoxelCoord)
    );
    assertTrue(faucetVelocity.x == 0);
    assertTrue(faucetVelocity.y == 1);
    assertTrue(faucetVelocity.z == 0);

    vm.stopPrank();
  }

  function testMoveAgentBounceBack() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory smallMassEntity;
    VoxelCoord memory smallMassCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      smallMassCoord = VoxelCoord({ x: agentCoord.x + 3, y: agentCoord.y, z: agentCoord.z });
      uint256 initMass = 10;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: -4, y: 0, z: 0 });
      smallMassEntity = world.spawnBody(
        voxelTypeId,
        smallMassCoord,
        bytes4(0),
        initMass,
        initEnergy,
        initVelocity,
        0,
        0
      );
    }

    VoxelCoord memory faucetCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory faucetEntity = world.buildWithAgent(FaucetVoxelID, faucetCoord, agentEntity, bytes4(0));
    Stamina.set(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId, 100);
    vm.startPrank(bob, bob);
    world.claimAgent(faucetEntity);
    vm.stopPrank();
    vm.startPrank(alice, alice);

    vm.roll(block.number + 1);
    VoxelCoord memory newfaucetCoord = VoxelCoord({ x: faucetCoord.x + 1, y: faucetCoord.y, z: faucetCoord.z });
    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    address agentOwner = OwnedBy.get(faucetEntity.scale, faucetEntity.entityId);
    console.log("owner before");
    console.logAddress(agentOwner);
    (, faucetEntity) = world.moveWithAgent(FaucetVoxelID, faucetCoord, newfaucetCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    assertTrue(staminaBefore > staminaAfter);
    assertTrue(Stamina.get(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId) == 100);
    assertTrue(OwnedBy.get(faucetEntity.scale, faucetEntity.entityId) == agentOwner);

    VoxelCoord memory faucetVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId),
      (VoxelCoord)
    );
    assertTrue(getEntityAtCoord(1, VoxelCoord(faucetCoord.x, faucetCoord.y, faucetCoord.z)) == faucetEntity.entityId);
    assertTrue(
      VoxelType.getVoxelTypeId(
        1,
        getEntityAtCoord(1, VoxelCoord(newfaucetCoord.x, newfaucetCoord.y, newfaucetCoord.z))
      ) == AirVoxelID
    );
    assertTrue(faucetVelocity.x == 0);
    assertTrue(faucetVelocity.y == 0);
    assertTrue(faucetVelocity.z == 0);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testMoveAgentCollisionPushedMultiple() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelEntity memory massEntity;
    VoxelCoord memory massCoord;
    {
      bytes32 voxelTypeId = GrassVoxelID;
      massCoord = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z - 1 });
      uint256 initMass = 5;
      uint256 initEnergy = 10;
      VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 10 });
      massEntity = world.spawnBody(voxelTypeId, massCoord, bytes4(0), initMass, initEnergy, initVelocity, 0, 0);
    }

    VoxelCoord memory faucetCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory faucetEntity = world.buildWithAgent(FaucetVoxelID, faucetCoord, agentEntity, bytes4(0));
    Stamina.set(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId, 100);
    vm.startPrank(bob, bob);
    world.claimAgent(faucetEntity);
    vm.stopPrank();
    vm.startPrank(alice, alice);

    vm.roll(block.number + 1);
    VoxelCoord memory newfaucetCoord = VoxelCoord({ x: faucetCoord.x + 1, y: faucetCoord.y, z: faucetCoord.z });
    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    address agentOwner = OwnedBy.get(faucetEntity.scale, faucetEntity.entityId);
    console.log("owner before");
    console.logAddress(agentOwner);
    (, faucetEntity) = world.moveWithAgent(FaucetVoxelID, faucetCoord, newfaucetCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    assertTrue(staminaBefore > staminaAfter);
    assertTrue(Stamina.get(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId) == 100);
    assertTrue(OwnedBy.get(faucetEntity.scale, faucetEntity.entityId) == agentOwner);

    VoxelCoord memory faucetVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId),
      (VoxelCoord)
    );
    assertTrue(faucetVelocity.x == 1);
    assertTrue(faucetVelocity.y == 0);
    assertTrue(faucetVelocity.z == 2);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, faucetEntity.scale, faucetEntity.entityId) > 0);

    massEntity = VoxelEntity({
      scale: 1,
      entityId: getEntityAtCoord(1, VoxelCoord(massCoord.x, massCoord.y, massCoord.z - 2))
    });
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, massEntity.scale, massEntity.entityId),
      (VoxelCoord)
    );
    console.log("velocity mass");
    assertTrue(massVelocity.x == 0);
    assertTrue(massVelocity.y == 0);
    assertTrue(massVelocity.z == 8);
    assertTrue(Mass.get(IStore(SIMULATOR_ADDRESS), worldAddress, massEntity.scale, massEntity.entityId) > 0);

    vm.stopPrank();
  }

  function testMoveAgentThatAutoSlowsDown() public {
    vm.startPrank(alice, alice);

    VoxelEntity memory agentEntity = setupAgent();

    VoxelCoord memory builderCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    VoxelEntity memory builderEntity = world.buildWithAgent(BuilderVoxelID, builderCoord, agentEntity, bytes4(0));
    Stamina.set(IStore(SIMULATOR_ADDRESS), worldAddress, builderEntity.scale, builderEntity.entityId, 100);
    vm.startPrank(bob, bob);
    world.claimAgent(builderEntity);
    vm.stopPrank();
    vm.startPrank(alice, alice);

    vm.roll(block.number + 1);
    VoxelCoord memory newBuilderCoord = VoxelCoord({ x: builderCoord.x, y: builderCoord.y + 1, z: builderCoord.z });
    uint256 staminaBefore = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    address agentOwner = OwnedBy.get(builderEntity.scale, builderEntity.entityId);
    console.log("owner before");
    console.logAddress(agentOwner);
    // Velocity.setVelocity(
    //   IStore(SIMULATOR_ADDRESS),
    //   worldAddress,
    //   builderEntity.scale,
    //   builderEntity.entityId,
    //   abi.encode(VoxelCoord({ x: 4, y: 0, z: 0 }))
    // );
    (, builderEntity) = world.moveWithAgent(BuilderVoxelID, builderCoord, newBuilderCoord, agentEntity);
    uint256 staminaAfter = Stamina.get(
      IStore(SIMULATOR_ADDRESS),
      worldAddress,
      agentEntity.scale,
      agentEntity.entityId
    );
    assertTrue(staminaBefore > staminaAfter);
    console.log("stamina");
    assertTrue(Stamina.get(IStore(SIMULATOR_ADDRESS), worldAddress, builderEntity.scale, builderEntity.entityId) < 100);
    assertTrue(OwnedBy.get(builderEntity.scale, builderEntity.entityId) == agentOwner);
    VoxelCoord memory builderVelocity = abi.decode(
      Velocity.getVelocity(IStore(SIMULATOR_ADDRESS), worldAddress, builderEntity.scale, builderEntity.entityId),
      (VoxelCoord)
    );
    assertTrue(builderVelocity.x == 0);
    assertTrue(builderVelocity.y == 0);
    assertTrue(builderVelocity.z == 0);

    vm.stopPrank();
  }
}
