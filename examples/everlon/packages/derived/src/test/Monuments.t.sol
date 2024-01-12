// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
import { IWorld as IDerivedWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
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
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { int32ToUint32, uint32ToInt32 } from "@tenet-utils/src/TypeUtils.sol";
import { BuilderObjectID, GrassObjectID, AirObjectID, DirtObjectID } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS, WORLD_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

import { MonumentsLeaderboard, MonumentsLeaderboardData, MonumentsLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { MonumentBounties, MonumentBountiesData, MonumentBountiesTableId } from "@tenet-derived/src/codegen/Tables.sol";

// TODO: Replace relative imports in IWorld.sol, instead of this hack
interface IWorld is IBaseWorld, IBuildSystem, IMineSystem, IMoveSystem, IActivateSystem, IFaucetSystem {

}

contract MonumentsTest is MudTest {
  IWorld private world;
  IDerivedWorld private derivedWorld;
  IStore private store;
  IStore private simStore;
  IStore private derivedStore;
  address payable internal alice;
  address payable internal bob;
  VoxelCoord faucetAgentCoord = VoxelCoord(50, 10, 50);
  VoxelCoord agentCoord;

  function setUp() public override {
    super.setUp();
    world = IWorld(WORLD_ADDRESS);
    derivedWorld = IDerivedWorld(worldAddress);
    store = IStore(WORLD_ADDRESS);
    simStore = IStore(SIMULATOR_ADDRESS);
    derivedStore = IStore(worldAddress);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    bob = payable(address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8));
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

  function testClaimArea() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory lowerSouthwestCorner = VoxelCoord({ x: agentCoord.x, y: 0, z: agentCoord.z });
    VoxelCoord memory size = VoxelCoord({ x: 10, y: 0, z: 10 });

    derivedWorld.claimMonumentsArea(agentObjectEntityId, lowerSouthwestCorner, size);
    MonumentsLeaderboardData memory monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z
    );
    assertTrue(monumentsLBData.owner == alice, "Owner not set correctly");
    assertTrue(monumentsLBData.agentObjectEntityId == agentObjectEntityId, "Agent object entity ID not set correctly");
    assertTrue(monumentsLBData.length == int32ToUint32(size.x), "Length not set correctly");
    assertTrue(monumentsLBData.width == int32ToUint32(size.z), "Width not set correctly");
    assertTrue(monumentsLBData.totalLikes == 0, "TotalLikes not set correctly");
    assertTrue(monumentsLBData.likedBy.length == 0, "LikedBy not set correctly");

    // should fail because already claimed
    vm.expectRevert();
    derivedWorld.claimMonumentsArea(
      agentObjectEntityId,
      VoxelCoord({ x: lowerSouthwestCorner.x + 1, y: lowerSouthwestCorner.y, z: lowerSouthwestCorner.z }),
      size
    );

    vm.stopPrank();
  }

  function testClaimAreaInvalidAgent() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory lowerSouthwestCorner = VoxelCoord({ x: agentCoord.x + 10, y: 0, z: agentCoord.z });
    VoxelCoord memory size = VoxelCoord({ x: 10, y: 0, z: 10 });

    vm.expectRevert();
    derivedWorld.claimMonumentsArea(agentObjectEntityId, lowerSouthwestCorner, size);

    vm.stopPrank();
  }

  function testLikeArea() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory lowerSouthwestCorner = VoxelCoord({ x: agentCoord.x, y: 0, z: agentCoord.z });
    VoxelCoord memory size = VoxelCoord({ x: 10, y: 0, z: 10 });

    derivedWorld.claimMonumentsArea(agentObjectEntityId, lowerSouthwestCorner, size);
    MonumentsLeaderboardData memory monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z
    );
    assertTrue(monumentsLBData.totalLikes == 0, "TotalLikes not set correctly");
    assertTrue(monumentsLBData.likedBy.length == 0, "LikedBy not set correctly");

    derivedWorld.likeMonumentsArea(lowerSouthwestCorner);
    monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z
    );
    assertTrue(monumentsLBData.totalLikes == 1, "TotalLikes not set correctly");
    assertTrue(monumentsLBData.likedBy.length == 1, "LikedBy not set correctly");
    assertTrue(monumentsLBData.likedBy[0] == alice, "LikedBy not set correctly");

    // should fail because already liked
    vm.expectRevert();
    derivedWorld.likeMonumentsArea(lowerSouthwestCorner);

    vm.stopPrank();
  }

  function testInvalidLikeArea() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory lowerSouthwestCorner = VoxelCoord({ x: agentCoord.x, y: agentCoord.y, z: agentCoord.z });
    // should fail because not claimed
    vm.expectRevert();
    derivedWorld.likeMonumentsArea(lowerSouthwestCorner);

    vm.stopPrank();
  }

  function testSingleLeaderboard() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory lowerSouthwestCorner = VoxelCoord({ x: agentCoord.x, y: 0, z: agentCoord.z });
    VoxelCoord memory size = VoxelCoord({ x: 10, y: 0, z: 10 });

    derivedWorld.claimMonumentsArea(agentObjectEntityId, lowerSouthwestCorner, size);
    MonumentsLeaderboardData memory monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z
    );

    derivedWorld.likeMonumentsArea(lowerSouthwestCorner);
    monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z
    );
    assertTrue(monumentsLBData.totalLikes == 1, "TotalLikes not set correctly");
    vm.stopPrank();

    vm.startPrank(bob, bob);
    derivedWorld.likeMonumentsArea(lowerSouthwestCorner);
    monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z
    );
    assertTrue(monumentsLBData.totalLikes == 2, "TotalLikes not set correctly");
    vm.stopPrank();
    vm.startPrank(alice, alice);

    derivedWorld.updateMonumentsLeaderboard();
    monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z
    );
    assertTrue(monumentsLBData.rank == 1, "Rank not set correctly");

    vm.stopPrank();
  }

  function testMultipleLeaderboard() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();
    bytes32 agentObjectTypeId = BuilderObjectID;

    VoxelCoord memory lowerSouthwestCorner1 = VoxelCoord({ x: agentCoord.x, y: 0, z: agentCoord.z });
    VoxelCoord memory size = VoxelCoord({ x: 10, y: 0, z: 10 });

    derivedWorld.claimMonumentsArea(agentObjectEntityId, lowerSouthwestCorner1, size);
    MonumentsLeaderboardData memory monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner1.x,
      lowerSouthwestCorner1.y,
      lowerSouthwestCorner1.z
    );
    assertTrue(monumentsLBData.owner == alice, "Owner not set correctly");
    assertTrue(monumentsLBData.totalLikes == 0, "TotalLikes not set correctly");
    assertTrue(monumentsLBData.rank == 1, "Default rank not set correctly");

    // move agent to new area (-1 in and x and z ten times) and claim that
    VoxelCoord memory oldCoord = agentCoord;
    VoxelCoord memory newCoord = VoxelCoord(oldCoord.x - 1, oldCoord.y, oldCoord.z - 1);
    for (uint i = 0; i < 10; i++) {
      world.move(agentObjectEntityId, agentObjectTypeId, oldCoord, newCoord);
      oldCoord = newCoord;
      newCoord = VoxelCoord(oldCoord.x - 1, oldCoord.y, oldCoord.z - 1);
      agentCoord = newCoord;
    }
    size = VoxelCoord({ x: 5, y: 0, z: 5 });
    VoxelCoord memory lowerSouthwestCorner2 = VoxelCoord(newCoord.x, 0, newCoord.z);
    derivedWorld.claimMonumentsArea(agentObjectEntityId, lowerSouthwestCorner2, size);
    monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner2.x,
      lowerSouthwestCorner2.y,
      lowerSouthwestCorner2.z
    );
    assertTrue(monumentsLBData.owner == alice, "Owner not set correctly");
    assertTrue(monumentsLBData.totalLikes == 0, "TotalLikes not set correctly");
    assertTrue(monumentsLBData.rank == 2, "Default rank not set correctly");

    derivedWorld.likeMonumentsArea(lowerSouthwestCorner2);
    monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner2.x,
      lowerSouthwestCorner2.y,
      lowerSouthwestCorner2.z
    );
    assertTrue(monumentsLBData.totalLikes == 1, "TotalLikes not set correctly");
    vm.stopPrank();

    vm.startPrank(bob, bob);
    derivedWorld.likeMonumentsArea(lowerSouthwestCorner2);
    monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner2.x,
      lowerSouthwestCorner2.y,
      lowerSouthwestCorner2.z
    );
    assertTrue(monumentsLBData.totalLikes == 2, "TotalLikes not set correctly");
    vm.stopPrank();
    vm.startPrank(alice, alice);

    derivedWorld.updateMonumentsLeaderboard();
    monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner2.x,
      lowerSouthwestCorner2.y,
      lowerSouthwestCorner2.z
    );
    assertTrue(monumentsLBData.rank == 1, "Rank not set correctly");

    monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner1.x,
      lowerSouthwestCorner1.y,
      lowerSouthwestCorner1.z
    );
    assertTrue(monumentsLBData.rank == 2, "Rank not set correctly");

    vm.stopPrank();
  }

  function testSimpleBounty() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();
    bytes32 agentObjectTypeId = BuilderObjectID;

    VoxelCoord memory lowerSouthwestCorner = VoxelCoord({ x: agentCoord.x, y: 0, z: agentCoord.z });
    VoxelCoord memory size = VoxelCoord({ x: 10, y: 0, z: 10 });

    derivedWorld.claimMonumentsArea(agentObjectEntityId, lowerSouthwestCorner, size);
    MonumentsLeaderboardData memory monumentsLBData = MonumentsLeaderboard.get(
      derivedStore,
      lowerSouthwestCorner.x,
      lowerSouthwestCorner.y,
      lowerSouthwestCorner.z
    );
    assertTrue(monumentsLBData.owner == alice, "Owner not set correctly");

    uint256 bountyAmount = 100;

    // T grass shape
    bytes32[] memory objectTypeIds = new bytes32[](5);
    objectTypeIds[0] = GrassObjectID;
    objectTypeIds[1] = GrassObjectID;
    objectTypeIds[2] = GrassObjectID;
    objectTypeIds[3] = DirtObjectID;
    objectTypeIds[4] = DirtObjectID;

    VoxelCoord[] memory relativePositions = new VoxelCoord[](5);
    relativePositions[0] = VoxelCoord({ x: 0, y: 0, z: 0 });
    relativePositions[1] = VoxelCoord({ x: 1, y: 0, z: 0 });
    relativePositions[2] = VoxelCoord({ x: 2, y: 0, z: 0 });
    relativePositions[3] = VoxelCoord({ x: 1, y: 1, z: 0 });
    relativePositions[4] = VoxelCoord({ x: 1, y: 2, z: 0 });

    bytes32 bountyId = derivedWorld.addMonumentBounty(
      bountyAmount,
      objectTypeIds,
      relativePositions,
      "Test Simple Bounty Name",
      "Test Simple Bounty Description"
    );
    MonumentBountiesData memory bountyData = MonumentBounties.get(derivedStore, bountyId);
    assertTrue(bountyData.creator == alice, "Creator not set correctly");
    assertTrue(bountyData.bountyAmount == bountyAmount, "BountyAmount not set correctly");
    assertTrue(bountyData.claimedBy == address(0), "ClaimedBy not set correctly");
    assertTrue(bountyData.objectTypeIds.length == objectTypeIds.length, "ObjectTypeIds not set correctly");
    assertTrue(
      abi.decode(bountyData.relativePositions, (VoxelCoord[])).length == relativePositions.length,
      "RelativePositions not set correctly"
    );
    assertTrue(bytes(bountyData.name).length > 0, "Name not set correctly");
    assertTrue(bytes(bountyData.description).length > 0, "Description not set correctly");

    VoxelCoord memory newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z + 1 });
    world.move(agentObjectEntityId, agentObjectTypeId, agentCoord, newAgentCoord);
    agentCoord = newAgentCoord;
    VoxelCoord memory baseWorldCoord = VoxelCoord({ x: newAgentCoord.x + 1, y: newAgentCoord.y, z: newAgentCoord.z });
    world.build(agentObjectEntityId, objectTypeIds[0], baseWorldCoord);

    // Should fail because doesn't match bounty
    vm.expectRevert();
    derivedWorld.claimMonumentBounty(bountyId, lowerSouthwestCorner, baseWorldCoord);

    newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z + 1 });
    world.move(agentObjectEntityId, agentObjectTypeId, agentCoord, newAgentCoord);
    agentCoord = newAgentCoord;

    newAgentCoord = VoxelCoord({ x: agentCoord.x + 1, y: agentCoord.y, z: agentCoord.z });
    world.move(agentObjectEntityId, agentObjectTypeId, agentCoord, newAgentCoord);
    agentCoord = newAgentCoord;

    world.build(
      agentObjectEntityId,
      objectTypeIds[1],
      VoxelCoord({
        x: baseWorldCoord.x + relativePositions[1].x,
        y: baseWorldCoord.y + relativePositions[1].y,
        z: baseWorldCoord.z + relativePositions[1].z
      })
    );
    world.build(
      agentObjectEntityId,
      objectTypeIds[2],
      VoxelCoord({
        x: baseWorldCoord.x + relativePositions[2].x,
        y: baseWorldCoord.y + relativePositions[2].y,
        z: baseWorldCoord.z + relativePositions[2].z
      })
    );
    world.build(
      agentObjectEntityId,
      objectTypeIds[3],
      VoxelCoord({
        x: baseWorldCoord.x + relativePositions[3].x,
        y: baseWorldCoord.y + relativePositions[3].y,
        z: baseWorldCoord.z + relativePositions[3].z
      })
    );

    newAgentCoord = VoxelCoord({ x: agentCoord.x, y: agentCoord.y + 1, z: agentCoord.z });
    world.move(agentObjectEntityId, agentObjectTypeId, agentCoord, newAgentCoord);
    agentCoord = newAgentCoord;

    // Build wrong object type
    world.build(
      agentObjectEntityId,
      GrassObjectID,
      VoxelCoord({
        x: baseWorldCoord.x + relativePositions[4].x,
        y: baseWorldCoord.y + relativePositions[4].y,
        z: baseWorldCoord.z + relativePositions[4].z
      })
    );

    // Should fail because doesn't match bounty
    vm.expectRevert();
    derivedWorld.claimMonumentBounty(bountyId, lowerSouthwestCorner, baseWorldCoord);

    world.mine(
      agentObjectEntityId,
      GrassObjectID,
      VoxelCoord({
        x: baseWorldCoord.x + relativePositions[4].x,
        y: baseWorldCoord.y + relativePositions[4].y,
        z: baseWorldCoord.z + relativePositions[4].z
      })
    );

    world.build(
      agentObjectEntityId,
      objectTypeIds[4],
      VoxelCoord({
        x: baseWorldCoord.x + relativePositions[4].x,
        y: baseWorldCoord.y + relativePositions[4].y,
        z: baseWorldCoord.z + relativePositions[4].z
      })
    );

    // Even if somebody else does the claim tx, only the claimed area owner
    // gets the bounty
    vm.startPrank(bob, bob);
    derivedWorld.claimMonumentBounty(bountyId, lowerSouthwestCorner, baseWorldCoord);
    bountyData = MonumentBounties.get(derivedStore, bountyId);
    assertTrue(bountyData.claimedBy == monumentsLBData.owner, "ClaimedBy not set correctly");
    vm.stopPrank();
    vm.startPrank(alice, alice);

    // Should fail because already claimed
    vm.expectRevert();
    derivedWorld.claimMonumentBounty(bountyId, lowerSouthwestCorner, baseWorldCoord);

    vm.stopPrank();
  }
}
