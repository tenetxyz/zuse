// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { ObjectType, OwnedBy, ObjectEntity } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { BuilderObjectID, GrassObjectID, AirObjectID, RunnerObjectID } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

contract CollisionTest is MudTest {
  IWorld private world;
  IStore private store;
  IStore private simStore;
  address payable internal alice;
  address payable internal bob;
  VoxelCoord faucetAgentCoord = VoxelCoord(197, 27, 203);
  VoxelCoord agentCoord;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    simStore = IStore(SIMULATOR_ADDRESS);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    bob = payable(address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8));
    agentCoord = VoxelCoord({ x: faucetAgentCoord.x + 1, y: faucetAgentCoord.y, z: faucetAgentCoord.z });
  }

  function setupAgent() internal returns (bytes32, bytes32) {
    bytes32 faucetEntityId = getEntityAtCoord(store, faucetAgentCoord);
    assertTrue(uint256(faucetEntityId) != 0, "Agent not found at coord");
    bytes32 faucetObjectEntityId = ObjectEntity.get(store, faucetEntityId);

    bytes32 agentObjectTypeId = RunnerObjectID;
    bytes32 agentEntityId = world.claimAgentFromFaucet(faucetObjectEntityId, agentObjectTypeId, agentCoord);
    assertTrue(uint256(agentEntityId) != 0, "Agent not found at coord");
    bytes32 agentObjectEntityId = ObjectEntity.get(store, agentEntityId);

    // Move away from the flag and reset velocity
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z)
    );
    agentCoord = VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z);
    // Set velocity to 0
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    return (agentEntityId, agentObjectEntityId);
  }

  function testMoveSelf() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory newCoord = VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z);
    world.move(agentObjectEntityId, RunnerObjectID, agentCoord, newCoord);
    bytes32 newEntityId = getEntityAtCoord(store, newCoord);
    bytes32 newCoordObjectEntityId = ObjectEntity.get(store, newEntityId);
    assertTrue(newCoordObjectEntityId == agentObjectEntityId, "Agent not moved");
    assertTrue(ObjectType.get(store, newEntityId) == RunnerObjectID, "Agent not moved");

    vm.stopPrank();
  }

  function testSimpleCollision() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    bytes32 massObjectEntityId;
    VoxelCoord memory massCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 massEntityId = world.build(agentObjectEntityId, GrassObjectID, massCoord);
      massObjectEntityId = ObjectEntity.get(store, massEntityId);
      Mass.set(simStore, worldAddress, massObjectEntityId, 1);
      Energy.set(simStore, worldAddress, massObjectEntityId, 10);
    }
    // Move back one
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z)
    );
    // Set velocity to 0
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    uint256 healthBefore = Health.getHealth(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    assertTrue(Health.getHealth(simStore, worldAddress, agentObjectEntityId) == healthBefore, "Health reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 1 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 1,0,0");

    // Mass should be at x + 1 coord
    bytes32 massEntityId = getEntityAtCoord(store, VoxelCoord(massCoord.x + 1, massCoord.y, massCoord.z));
    massObjectEntityId = ObjectEntity.get(store, massEntityId);
    assertTrue(ObjectType.get(store, massEntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, massObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(massVelocity.x == 1 && massVelocity.y == 0 && massVelocity.z == 0, "Mass velocity not 1,0,0");

    vm.stopPrank();
  }

  function testCollisionBounceBack() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    bytes32 massObjectEntityId;
    VoxelCoord memory massCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 massEntityId = world.build(agentObjectEntityId, GrassObjectID, massCoord);
      massObjectEntityId = ObjectEntity.get(store, massEntityId);
      Mass.set(simStore, worldAddress, massObjectEntityId, 5);
      Energy.set(simStore, worldAddress, massObjectEntityId, 10);
    }
    // Move back one
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z)
    );
    // Set velocity to 4, 0, 0
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 4, y: 0, z: 0 })));

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    uint256 healthBefore = Health.getHealth(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    assertTrue(Health.getHealth(simStore, worldAddress, agentObjectEntityId) < healthBefore, "Health not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 4 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 4,0,0");

    // Mass should be at x + 1 coord
    bytes32 massEntityId = getEntityAtCoord(store, VoxelCoord(massCoord.x + 1, massCoord.y, massCoord.z));
    massObjectEntityId = ObjectEntity.get(store, massEntityId);
    assertTrue(ObjectType.get(store, massEntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, massObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(massVelocity.x == 1 && massVelocity.y == 0 && massVelocity.z == 0, "Mass velocity not 1,0,0");

    vm.stopPrank();
  }

  function testCollisionMultipleObjectsPushed() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    bytes32 massObjectEntityId;
    VoxelCoord memory massCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z - 1 });
    {
      bytes32 massEntityId = world.build(agentObjectEntityId, GrassObjectID, massCoord);
      massObjectEntityId = ObjectEntity.get(store, massEntityId);
      Mass.set(simStore, worldAddress, massObjectEntityId, 5);
      Energy.set(simStore, worldAddress, massObjectEntityId, 10);
      Velocity.setVelocity(simStore, worldAddress, massObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 10 })));
    }

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    uint256 healthBefore = Health.getHealth(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z)
    );
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    assertTrue(Health.getHealth(simStore, worldAddress, agentObjectEntityId) < healthBefore, "Health not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 1 && agentVelocity.y == 0 && agentVelocity.z == 2, "Agent velocity not 1,0,2");

    // Mass should be at x + 1 coord
    bytes32 massEntityId = getEntityAtCoord(store, VoxelCoord(massCoord.x, massCoord.y, massCoord.z - 2));
    massObjectEntityId = ObjectEntity.get(store, massEntityId);
    assertTrue(ObjectType.get(store, massEntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, massObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(massVelocity.x == 0 && massVelocity.y == 0 && massVelocity.z == 8, "Mass velocity not 0,0,8");

    vm.stopPrank();
  }

  function testCollisionMoveTwo() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    bytes32 mass1ObjectEntityId;
    VoxelCoord memory mass1Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 mass1EntityId = world.build(agentObjectEntityId, GrassObjectID, mass1Coord);
      mass1ObjectEntityId = ObjectEntity.get(store, mass1EntityId);
      Mass.set(simStore, worldAddress, mass1ObjectEntityId, 5);
      Energy.set(simStore, worldAddress, mass1ObjectEntityId, 10);
    }
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z + 1)
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    bytes32 mass2ObjectEntityId;
    VoxelCoord memory mass2Coord = VoxelCoord({ x: mass1Coord.x + 1, y: mass1Coord.y, z: mass1Coord.z });
    {
      bytes32 mass2EntityId = world.build(agentObjectEntityId, GrassObjectID, mass2Coord);
      mass2ObjectEntityId = ObjectEntity.get(store, mass2EntityId);
      Mass.set(simStore, worldAddress, mass2ObjectEntityId, 1);
      Energy.set(simStore, worldAddress, mass2ObjectEntityId, 10);
    }
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z + 1),
      agentCoord
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z)
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    Mass.set(simStore, worldAddress, mass1ObjectEntityId, 1);

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 1 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 1,0,0");

    // Mass should be at x + 1 coord
    bytes32 mass1EntityId = getEntityAtCoord(store, VoxelCoord(mass1Coord.x + 1, mass1Coord.y, mass1Coord.z));
    mass1ObjectEntityId = ObjectEntity.get(store, mass1EntityId);
    assertTrue(ObjectType.get(store, mass1EntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory mass1Velocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, mass1ObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(mass1Velocity.x == 1 && mass1Velocity.y == 0 && mass1Velocity.z == 0, "Mass velocity not 1,0,0");

    // Mass should be at x + 1 coord
    bytes32 mass2EntityId = getEntityAtCoord(store, VoxelCoord(mass2Coord.x + 1, mass2Coord.y, mass2Coord.z));
    mass2ObjectEntityId = ObjectEntity.get(store, mass2EntityId);
    assertTrue(ObjectType.get(store, mass2EntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory mass2Velocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, mass2ObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(mass2Velocity.x == 1 && mass2Velocity.y == 0 && mass2Velocity.z == 0, "Mass velocity not 1,0,0");

    vm.stopPrank();
  }

  function testCollisionNoVelocityChange() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    bytes32 massObjectEntityId;
    VoxelCoord memory massCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 massEntityId = world.build(agentObjectEntityId, GrassObjectID, massCoord);
      massObjectEntityId = ObjectEntity.get(store, massEntityId);
      Mass.set(simStore, worldAddress, massObjectEntityId, 1);
      Energy.set(simStore, worldAddress, massObjectEntityId, 10);
      Velocity.setVelocity(simStore, worldAddress, massObjectEntityId, abi.encode(VoxelCoord({ x: 1, y: 0, z: 0 })));
    }
    // Move back one
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z)
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 1 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 1,0,0");

    bytes32 massEntityId = getEntityAtCoord(store, VoxelCoord(massCoord.x, massCoord.y, massCoord.z));
    massObjectEntityId = ObjectEntity.get(store, massEntityId);
    assertTrue(ObjectType.get(store, massEntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, massObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(massVelocity.x == 1 && massVelocity.y == 0 && massVelocity.z == 0, "Mass velocity not 1,0,0");

    vm.stopPrank();
  }

  function testCollisionSameDirection() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    bytes32 massObjectEntityId;
    VoxelCoord memory massCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 massEntityId = world.build(agentObjectEntityId, GrassObjectID, massCoord);
      massObjectEntityId = ObjectEntity.get(store, massEntityId);
      Mass.set(simStore, worldAddress, massObjectEntityId, 1);
      Energy.set(simStore, worldAddress, massObjectEntityId, 10);
      Velocity.setVelocity(simStore, worldAddress, massObjectEntityId, abi.encode(VoxelCoord({ x: 1, y: 0, z: 0 })));
    }
    // Move back one
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z)
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 4, y: 0, z: 0 })));

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 5 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 5,0,0");

    bytes32 massEntityId = getEntityAtCoord(store, VoxelCoord(massCoord.x + 4, massCoord.y, massCoord.z));
    massObjectEntityId = ObjectEntity.get(store, massEntityId);
    assertTrue(ObjectType.get(store, massEntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, massObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(massVelocity.x == 5 && massVelocity.y == 0 && massVelocity.z == 0, "Mass velocity not 5,0,0");

    vm.stopPrank();
  }

  function testCollisionOppositeDirectionEqualVelocityDifferentMass() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    bytes32 massObjectEntityId;
    VoxelCoord memory massCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 massEntityId = world.build(agentObjectEntityId, GrassObjectID, massCoord);
      massObjectEntityId = ObjectEntity.get(store, massEntityId);
      Mass.set(simStore, worldAddress, massObjectEntityId, 1);
      Energy.set(simStore, worldAddress, massObjectEntityId, 10);
      Velocity.setVelocity(simStore, worldAddress, massObjectEntityId, abi.encode(VoxelCoord({ x: -1, y: 0, z: 0 })));
    }
    // Move back one
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z)
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 1 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 1,0,0");

    bytes32 massEntityId = getEntityAtCoord(store, VoxelCoord(massCoord.x + 2, massCoord.y, massCoord.z));
    massObjectEntityId = ObjectEntity.get(store, massEntityId);
    assertTrue(ObjectType.get(store, massEntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, massObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(massVelocity.x == 1 && massVelocity.y == 0 && massVelocity.z == 0, "Mass velocity not 1,0,0");

    vm.stopPrank();
  }

  function testCollisionOppositeDirectionEqualVelocityEqualMass() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    bytes32 massObjectEntityId;
    VoxelCoord memory massCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 massEntityId = world.build(agentObjectEntityId, GrassObjectID, massCoord);
      massObjectEntityId = ObjectEntity.get(store, massEntityId);
      Mass.set(simStore, worldAddress, massObjectEntityId, 5);
      Energy.set(simStore, worldAddress, massObjectEntityId, 10);
      Velocity.setVelocity(simStore, worldAddress, massObjectEntityId, abi.encode(VoxelCoord({ x: -1, y: 0, z: 0 })));
    }
    // Move back one
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z)
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x - 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 1 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 1,0,0");

    bytes32 massEntityId = getEntityAtCoord(store, VoxelCoord(massCoord.x, massCoord.y, massCoord.z));
    massObjectEntityId = ObjectEntity.get(store, massEntityId);
    assertTrue(ObjectType.get(store, massEntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, massObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(massVelocity.x == -1 && massVelocity.y == 0 && massVelocity.z == 0, "Mass velocity not -1,0,0");

    vm.stopPrank();
  }

  function testMoveObject() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    VoxelCoord memory oldCoord = VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z);
    bytes32 massEntityId = world.build(agentObjectEntityId, GrassObjectID, oldCoord);
    bytes32 massObjectEntityId = ObjectEntity.get(store, massEntityId);
    VoxelCoord memory newCoord = VoxelCoord(oldCoord.x + 1, oldCoord.y, oldCoord.z);
    // Old coord should not be air
    bytes32 moveObjectTypeId = ObjectType.get(store, getEntityAtCoord(store, oldCoord));
    assertTrue(moveObjectTypeId == GrassObjectID, "Old coord is air");
    // New coord should be air
    assertTrue(world.getTerrainObjectTypeId(newCoord) == AirObjectID, "New coord not air");

    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(agentObjectEntityId, moveObjectTypeId, oldCoord, newCoord);
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 0,0,0");

    // Old coord should be air
    assertTrue(ObjectType.get(store, getEntityAtCoord(store, oldCoord)) == AirObjectID, "Old coord not air");
    // New coord should be moving object
    assertTrue(ObjectType.get(store, getEntityAtCoord(store, newCoord)) == moveObjectTypeId, "New coord is air");
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, massObjectEntityId),
      (VoxelCoord)
    );

    assertTrue(massVelocity.x == 1 && massVelocity.y == 0 && massVelocity.z == 0, "Mass velocity not 1,0,0");

    vm.stopPrank();
  }

  function testMoveObjectBounceBack() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z)
    );
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z),
      VoxelCoord(agentCoord.x + 2, agentCoord.y, agentCoord.z)
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    bytes32 mass1ObjectEntityId;
    VoxelCoord memory mass1Coord = VoxelCoord({ x: agentCoord.x + 3, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 mass1EntityId = world.build(agentObjectEntityId, GrassObjectID, mass1Coord);
      mass1ObjectEntityId = ObjectEntity.get(store, mass1EntityId);
      Mass.set(simStore, worldAddress, mass1ObjectEntityId, 10);
      Energy.set(simStore, worldAddress, mass1ObjectEntityId, 10);
      Velocity.setVelocity(simStore, worldAddress, mass1ObjectEntityId, abi.encode(VoxelCoord({ x: -4, y: 0, z: 0 })));
    }

    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x + 2, agentCoord.y, agentCoord.z),
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z)
    );
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    bytes32 mass2ObjectEntityId;
    VoxelCoord memory mass2Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 mass2EntityId = world.build(agentObjectEntityId, GrassObjectID, mass2Coord);
      mass2ObjectEntityId = ObjectEntity.get(store, mass2EntityId);
      Mass.set(simStore, worldAddress, mass2ObjectEntityId, 5);
      Energy.set(simStore, worldAddress, mass2ObjectEntityId, 10);
    }

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      GrassObjectID,
      mass2Coord,
      VoxelCoord(mass2Coord.x + 1, mass2Coord.y, mass2Coord.z)
    );
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 0,0,0");

    bytes32 mass1EntityId = getEntityAtCoord(store, VoxelCoord(mass1Coord.x, mass1Coord.y, mass1Coord.z));
    mass1ObjectEntityId = ObjectEntity.get(store, mass1EntityId);
    assertTrue(ObjectType.get(store, mass1EntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory mass1Velocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, mass1ObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(mass1Velocity.x == -4 && mass1Velocity.y == 0 && mass1Velocity.z == 0, "Mass velocity not -4,0,0");

    bytes32 mass2EntityId = getEntityAtCoord(store, VoxelCoord(mass2Coord.x, mass2Coord.y, mass2Coord.z));
    mass2ObjectEntityId = ObjectEntity.get(store, mass2EntityId);
    assertTrue(ObjectType.get(store, mass2EntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory mass2Velocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, mass2ObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(mass2Velocity.x == 0 && mass2Velocity.y == 0 && mass2Velocity.z == 0, "Mass velocity not 0,0,0");

    vm.stopPrank();
  }

  function testMoveObjectCollisionPushedMultiple() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z)
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    bytes32 mass1ObjectEntityId;
    VoxelCoord memory mass1Coord = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z - 1 });
    {
      bytes32 mass1EntityId = world.build(agentObjectEntityId, GrassObjectID, mass1Coord);
      mass1ObjectEntityId = ObjectEntity.get(store, mass1EntityId);
      Mass.set(simStore, worldAddress, mass1ObjectEntityId, 5);
      Energy.set(simStore, worldAddress, mass1ObjectEntityId, 10);
      Velocity.setVelocity(simStore, worldAddress, mass1ObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 10 })));
    }

    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    bytes32 mass2ObjectEntityId;
    VoxelCoord memory mass2Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 mass2EntityId = world.build(agentObjectEntityId, GrassObjectID, mass2Coord);
      mass2ObjectEntityId = ObjectEntity.get(store, mass2EntityId);
      Mass.set(simStore, worldAddress, mass2ObjectEntityId, 5);
      Energy.set(simStore, worldAddress, mass2ObjectEntityId, 10);
    }

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      GrassObjectID,
      mass2Coord,
      VoxelCoord(mass2Coord.x + 1, mass2Coord.y, mass2Coord.z)
    );
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 0,0,0");

    bytes32 mass1EntityId = getEntityAtCoord(store, VoxelCoord(mass1Coord.x, mass1Coord.y, mass1Coord.z - 2));
    mass1ObjectEntityId = ObjectEntity.get(store, mass1EntityId);
    assertTrue(ObjectType.get(store, mass1EntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory mass1Velocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, mass1ObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(mass1Velocity.x == 0 && mass1Velocity.y == 0 && mass1Velocity.z == 8, "Mass velocity not 0,0,8");

    bytes32 mass2EntityId = getEntityAtCoord(store, VoxelCoord(mass2Coord.x + 1, mass2Coord.y, mass2Coord.z + 2));
    mass2ObjectEntityId = ObjectEntity.get(store, mass2EntityId);
    assertTrue(ObjectType.get(store, mass2EntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory mass2Velocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, mass2ObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(mass2Velocity.x == 1 && mass2Velocity.y == 0 && mass2Velocity.z == 2, "Mass velocity not 1,0,2");

    vm.stopPrank();
  }

  function testMoveAgent() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    bytes32 massObjectEntityId;
    VoxelCoord memory massCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 massEntityId = world.build(agentObjectEntityId, RunnerObjectID, massCoord);
      massObjectEntityId = ObjectEntity.get(store, massEntityId);
      Mass.set(simStore, worldAddress, massObjectEntityId, 5);
      Energy.set(simStore, worldAddress, massObjectEntityId, 10);
      Health.setHealth(simStore, worldAddress, massObjectEntityId, 100);
      Stamina.set(simStore, worldAddress, massObjectEntityId, 100);

      // Make the owner of the agent different from the one moving it
      vm.startPrank(bob, bob);
      world.claimAgent(massEntityId);
      assertTrue(OwnedBy.get(store, massObjectEntityId) == bob, "Owner not bob");
      vm.stopPrank();
      vm.startPrank(alice, alice);
    }

    VoxelCoord memory newMassCoord = VoxelCoord(massCoord.x + 1, massCoord.y, massCoord.z);

    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(agentObjectEntityId, RunnerObjectID, massCoord, newMassCoord);
    assertTrue(OwnedBy.get(store, massObjectEntityId) == bob, "Owner not bob");
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    assertTrue(Stamina.get(simStore, worldAddress, massObjectEntityId) == 100, "Stamina reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 0,0,0");

    // Old coord should be air
    assertTrue(ObjectType.get(store, getEntityAtCoord(store, massCoord)) == AirObjectID, "Old coord not air");
    // New coord should be moving object
    assertTrue(ObjectType.get(store, getEntityAtCoord(store, newMassCoord)) == RunnerObjectID, "New coord is air");
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, massObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(massVelocity.x == 1 && massVelocity.y == 0 && massVelocity.z == 0, "Mass velocity not 1,0,0");

    vm.stopPrank();
  }

  function testMoveAgentBounceBack() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z)
    );
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z),
      VoxelCoord(agentCoord.x + 2, agentCoord.y, agentCoord.z)
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    bytes32 mass1ObjectEntityId;
    VoxelCoord memory mass1Coord = VoxelCoord({ x: agentCoord.x + 3, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 mass1EntityId = world.build(agentObjectEntityId, GrassObjectID, mass1Coord);
      mass1ObjectEntityId = ObjectEntity.get(store, mass1EntityId);
      Mass.set(simStore, worldAddress, mass1ObjectEntityId, 10);
      Energy.set(simStore, worldAddress, mass1ObjectEntityId, 10);
      Velocity.setVelocity(simStore, worldAddress, mass1ObjectEntityId, abi.encode(VoxelCoord({ x: -4, y: 0, z: 0 })));
    }

    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x + 2, agentCoord.y, agentCoord.z),
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z)
    );
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    bytes32 mass2ObjectEntityId;
    VoxelCoord memory mass2Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 mass2EntityId = world.build(agentObjectEntityId, RunnerObjectID, mass2Coord);
      mass2ObjectEntityId = ObjectEntity.get(store, mass2EntityId);
      Mass.set(simStore, worldAddress, mass2ObjectEntityId, 5);
      Energy.set(simStore, worldAddress, mass2ObjectEntityId, 10);
      Health.setHealth(simStore, worldAddress, mass2ObjectEntityId, 100);
      Stamina.set(simStore, worldAddress, mass2ObjectEntityId, 100);

      // Make the owner of the agent different from the one moving it
      vm.startPrank(bob, bob);
      world.claimAgent(mass2EntityId);
      assertTrue(OwnedBy.get(store, mass2ObjectEntityId) == bob, "Owner not bob");
      vm.stopPrank();
      vm.startPrank(alice, alice);
    }

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      mass2Coord,
      VoxelCoord(mass2Coord.x + 1, mass2Coord.y, mass2Coord.z)
    );
    assertTrue(OwnedBy.get(store, mass2ObjectEntityId) == bob, "Owner not bob");
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    assertTrue(Stamina.get(simStore, worldAddress, mass2ObjectEntityId) == 100, "Stamina reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 0,0,0");

    bytes32 mass1EntityId = getEntityAtCoord(store, VoxelCoord(mass1Coord.x, mass1Coord.y, mass1Coord.z));
    mass1ObjectEntityId = ObjectEntity.get(store, mass1EntityId);
    assertTrue(ObjectType.get(store, mass1EntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory mass1Velocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, mass1ObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(mass1Velocity.x == -4 && mass1Velocity.y == 0 && mass1Velocity.z == 0, "Mass velocity not -4,0,0");

    bytes32 mass2EntityId = getEntityAtCoord(store, VoxelCoord(mass2Coord.x, mass2Coord.y, mass2Coord.z));
    mass2ObjectEntityId = ObjectEntity.get(store, mass2EntityId);
    assertTrue(ObjectType.get(store, mass2EntityId) == RunnerObjectID, "Mass not found");
    VoxelCoord memory mass2Velocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, mass2ObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(mass2Velocity.x == 0 && mass2Velocity.y == 0 && mass2Velocity.z == 0, "Mass velocity not 0,0,0");

    vm.stopPrank();
  }

  function testMoveAgentCollisionPushedMultiple() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      agentCoord,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z)
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    bytes32 mass1ObjectEntityId;
    VoxelCoord memory mass1Coord = VoxelCoord({ x: agentCoord.x + 2, y: agentCoord.y, z: agentCoord.z - 1 });
    {
      bytes32 mass1EntityId = world.build(agentObjectEntityId, GrassObjectID, mass1Coord);
      mass1ObjectEntityId = ObjectEntity.get(store, mass1EntityId);
      Mass.set(simStore, worldAddress, mass1ObjectEntityId, 5);
      Energy.set(simStore, worldAddress, mass1ObjectEntityId, 10);
      Velocity.setVelocity(simStore, worldAddress, mass1ObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 10 })));
    }

    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      VoxelCoord(agentCoord.x + 1, agentCoord.y, agentCoord.z),
      agentCoord
    );
    Velocity.setVelocity(simStore, worldAddress, agentObjectEntityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    bytes32 mass2ObjectEntityId;
    VoxelCoord memory mass2Coord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 mass2EntityId = world.build(agentObjectEntityId, RunnerObjectID, mass2Coord);
      mass2ObjectEntityId = ObjectEntity.get(store, mass2EntityId);
      Mass.set(simStore, worldAddress, mass2ObjectEntityId, 5);
      Energy.set(simStore, worldAddress, mass2ObjectEntityId, 10);
      Health.setHealth(simStore, worldAddress, mass2ObjectEntityId, 100);
      Stamina.set(simStore, worldAddress, mass2ObjectEntityId, 100);

      // Make the owner of the agent different from the one moving it
      vm.startPrank(bob, bob);
      world.claimAgent(mass2EntityId);
      assertTrue(OwnedBy.get(store, mass2ObjectEntityId) == bob, "Owner not bob");
      vm.stopPrank();
      vm.startPrank(alice, alice);
    }

    // Now move forward one
    // This will cause the collision
    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(
      agentObjectEntityId,
      RunnerObjectID,
      mass2Coord,
      VoxelCoord(mass2Coord.x + 1, mass2Coord.y, mass2Coord.z)
    );
    assertTrue(OwnedBy.get(store, mass2ObjectEntityId) == bob, "Owner not bob");
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    assertTrue(Stamina.get(simStore, worldAddress, mass2ObjectEntityId) == 100, "Stamina reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 0,0,0");

    bytes32 mass1EntityId = getEntityAtCoord(store, VoxelCoord(mass1Coord.x, mass1Coord.y, mass1Coord.z - 2));
    mass1ObjectEntityId = ObjectEntity.get(store, mass1EntityId);
    assertTrue(ObjectType.get(store, mass1EntityId) == GrassObjectID, "Mass not found");
    VoxelCoord memory mass1Velocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, mass1ObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(mass1Velocity.x == 0 && mass1Velocity.y == 0 && mass1Velocity.z == 8, "Mass velocity not 0,0,8");

    bytes32 mass2EntityId = getEntityAtCoord(store, VoxelCoord(mass2Coord.x + 1, mass2Coord.y, mass2Coord.z + 2));
    mass2ObjectEntityId = ObjectEntity.get(store, mass2EntityId);
    assertTrue(ObjectType.get(store, mass2EntityId) == RunnerObjectID, "Mass not found");
    VoxelCoord memory mass2Velocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, mass2ObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(mass2Velocity.x == 1 && mass2Velocity.y == 0 && mass2Velocity.z == 2, "Mass velocity not 1,0,2");

    vm.stopPrank();
  }

  function testMoveAgentThatStops() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();
    Mass.set(simStore, worldAddress, agentObjectEntityId, 5);

    bytes32 massObjectEntityId;
    VoxelCoord memory massCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    {
      bytes32 massEntityId = world.build(agentObjectEntityId, BuilderObjectID, massCoord);
      massObjectEntityId = ObjectEntity.get(store, massEntityId);
      Mass.set(simStore, worldAddress, massObjectEntityId, 5);
      Energy.set(simStore, worldAddress, massObjectEntityId, 10);
      Health.setHealth(simStore, worldAddress, massObjectEntityId, 100);
      Stamina.set(simStore, worldAddress, massObjectEntityId, 100);

      // Make the owner of the agent different from the one moving it
      vm.startPrank(bob, bob);
      world.claimAgent(massEntityId);
      assertTrue(OwnedBy.get(store, massObjectEntityId) == bob, "Owner not bob");
      vm.stopPrank();
      vm.startPrank(alice, alice);
    }

    VoxelCoord memory newMassCoord = VoxelCoord(massCoord.x + 1, massCoord.y, massCoord.z);

    uint256 staminaBefore = Stamina.get(simStore, worldAddress, agentObjectEntityId);
    world.move(agentObjectEntityId, BuilderObjectID, massCoord, newMassCoord);
    assertTrue(OwnedBy.get(store, massObjectEntityId) == bob, "Owner not bob");
    assertTrue(Stamina.get(simStore, worldAddress, agentObjectEntityId) < staminaBefore, "Stamina not reduced");
    assertTrue(Stamina.get(simStore, worldAddress, massObjectEntityId) < 100, "Stamina not reduced");
    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent velocity not 0,0,0");

    // Old coord should be air
    assertTrue(ObjectType.get(store, getEntityAtCoord(store, massCoord)) == AirObjectID, "Old coord not air");
    // New coord should be moving object
    assertTrue(ObjectType.get(store, getEntityAtCoord(store, newMassCoord)) == BuilderObjectID, "New coord is air");
    VoxelCoord memory massVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, massObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(massVelocity.x == 0 && massVelocity.y == 0 && massVelocity.z == 0, "Mass velocity not 0,0,0");

    vm.stopPrank();
  }
}
