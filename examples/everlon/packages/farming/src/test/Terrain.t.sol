// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/store/src/MudTest.sol";
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
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { SIMULATOR_ADDRESS, BuilderObjectID, GrassObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";
import { WORLD_ADDRESS, SOIL_MASS, PlantObjectID, ConcentrativeSoilObjectID, DiffusiveSoilObjectID, ProteinSoilObjectID, ElixirSoilObjectID } from "@tenet-farming/src/Constants.sol";
import { REGISTRY_ADDRESS } from "@tenet-farming/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Nutrients } from "@tenet-simulator/src/codegen/tables/Nutrients.sol";
import { Nitrogen } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorus } from "@tenet-simulator/src/codegen/tables/Phosphorus.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Potassium } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { Protein } from "@tenet-simulator/src/codegen/tables/Protein.sol";
import { Elixir } from "@tenet-simulator/src/codegen/tables/Elixir.sol";

// TODO: Replace relative imports in IWorld.sol, instead of this hack
interface IWorld is IBaseWorld, IBuildSystem, IMineSystem, IMoveSystem, IActivateSystem, IFaucetSystem {

}

contract TerrainTest is MudTest {
  IWorld private world;
  IStore private store;
  IStore private simStore;
  address payable internal alice;
  VoxelCoord faucetAgentCoord = VoxelCoord(259, 9, 60);
  VoxelCoord agentCoord;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
    store = IStore(worldAddress);
    simStore = IStore(SIMULATOR_ADDRESS);
    alice = payable(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));
    agentCoord = VoxelCoord({ x: faucetAgentCoord.x - 1, y: faucetAgentCoord.y, z: faucetAgentCoord.z });
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

  function testMoveOverSoil() public {
    vm.startPrank(alice, alice);
    (, bytes32 agentObjectEntityId) = setupAgent();

    vm.roll(block.number + 1);
    VoxelCoord memory oldCoord = agentCoord;
    VoxelCoord memory newCoord = VoxelCoord({ x: oldCoord.x - 1, y: oldCoord.y - 1, z: oldCoord.z });
    world.move(agentObjectEntityId, BuilderObjectID, oldCoord, newCoord);

    VoxelCoord memory agentVelocity = abi.decode(
      Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId),
      (VoxelCoord)
    );
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent has final velocity");

    vm.roll(block.number + 1);
    oldCoord = newCoord;
    newCoord = VoxelCoord({ x: oldCoord.x - 1, y: oldCoord.y, z: oldCoord.z });
    world.move(agentObjectEntityId, BuilderObjectID, oldCoord, newCoord);

    agentVelocity = abi.decode(Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId), (VoxelCoord));
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent has final velocity");

    vm.roll(block.number + 1);
    oldCoord = newCoord;
    newCoord = VoxelCoord({ x: oldCoord.x - 1, y: oldCoord.y, z: oldCoord.z });
    world.move(agentObjectEntityId, BuilderObjectID, oldCoord, newCoord);

    agentVelocity = abi.decode(Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId), (VoxelCoord));
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent has final velocity");

    vm.roll(block.number + 1);
    oldCoord = newCoord;
    newCoord = VoxelCoord({ x: oldCoord.x - 1, y: oldCoord.y, z: oldCoord.z });
    world.move(agentObjectEntityId, BuilderObjectID, oldCoord, newCoord);

    agentVelocity = abi.decode(Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId), (VoxelCoord));
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent has final velocity");

    vm.roll(block.number + 1);
    oldCoord = newCoord;
    newCoord = VoxelCoord({ x: oldCoord.x - 1, y: oldCoord.y, z: oldCoord.z });
    world.move(agentObjectEntityId, BuilderObjectID, oldCoord, newCoord);

    agentVelocity = abi.decode(Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId), (VoxelCoord));
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent has final velocity");

    vm.roll(block.number + 1);
    oldCoord = newCoord;
    newCoord = VoxelCoord({ x: oldCoord.x - 1, y: oldCoord.y - 1, z: oldCoord.z });
    world.move(agentObjectEntityId, BuilderObjectID, oldCoord, newCoord);

    agentVelocity = abi.decode(Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId), (VoxelCoord));
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent has final velocity");

    // Next move is over soil
    vm.roll(block.number + 1);
    oldCoord = newCoord;
    newCoord = VoxelCoord({ x: oldCoord.x - 1, y: oldCoord.y, z: oldCoord.z });
    world.move(agentObjectEntityId, BuilderObjectID, oldCoord, newCoord);

    agentVelocity = abi.decode(Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId), (VoxelCoord));
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent has final velocity");

    vm.roll(block.number + 1);
    oldCoord = newCoord;
    newCoord = VoxelCoord({ x: oldCoord.x - 1, y: oldCoord.y, z: oldCoord.z });
    world.move(agentObjectEntityId, BuilderObjectID, oldCoord, newCoord);

    agentVelocity = abi.decode(Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId), (VoxelCoord));
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent has final velocity");

    vm.roll(block.number + 1);
    oldCoord = newCoord;
    newCoord = VoxelCoord({ x: oldCoord.x - 1, y: oldCoord.y, z: oldCoord.z });
    world.move(agentObjectEntityId, BuilderObjectID, oldCoord, newCoord);
    agentVelocity = abi.decode(Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId), (VoxelCoord));
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent has final velocity");

    vm.roll(block.number + 1);
    oldCoord = newCoord;
    newCoord = VoxelCoord({ x: oldCoord.x - 1, y: oldCoord.y, z: oldCoord.z - 1 });
    world.move(agentObjectEntityId, BuilderObjectID, oldCoord, newCoord);

    agentVelocity = abi.decode(Velocity.getVelocity(simStore, worldAddress, agentObjectEntityId), (VoxelCoord));
    assertTrue(agentVelocity.x == 0 && agentVelocity.y == 0 && agentVelocity.z == 0, "Agent has final velocity");

    vm.stopPrank();
  }
}
