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
import { BuilderObjectID, GrassObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS, WORLD_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

import { MonumentsLeaderboard, MonumentsLeaderboardData, MonumentsLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";

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

    VoxelCoord memory lowerSouthwestCorner = VoxelCoord({ x: agentCoord.x, y: agentCoord.y, z: agentCoord.z });
    VoxelCoord memory size = VoxelCoord({ x: 10, y: 0, z: 10 });

    derivedWorld.claimArea(agentObjectEntityId, lowerSouthwestCorner, size);
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
    assertTrue(monumentsLBData.likedBy.length == 0, "LikedBy not set correctly");

    vm.expectRevert();
    // should fail because already claimed
    derivedWorld.claimArea(
      agentObjectEntityId,
      VoxelCoord({ x: lowerSouthwestCorner.x + 1, y: lowerSouthwestCorner.y, z: lowerSouthwestCorner.z }),
      size
    );

    vm.stopPrank();
  }

  function testClaimAreaInvalidAgent() public {
    vm.startPrank(alice, alice);

    (, bytes32 agentObjectEntityId) = setupAgent();

    VoxelCoord memory lowerSouthwestCorner = VoxelCoord({ x: agentCoord.x + 10, y: agentCoord.y, z: agentCoord.z });
    VoxelCoord memory size = VoxelCoord({ x: 10, y: 0, z: 10 });

    vm.expectRevert();
    derivedWorld.claimArea(agentObjectEntityId, lowerSouthwestCorner, size);

    vm.stopPrank();
  }
}
