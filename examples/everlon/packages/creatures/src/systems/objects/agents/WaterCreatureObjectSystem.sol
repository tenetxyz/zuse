// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-creatures/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-world/src/prototypes/AgentType.sol";
import { registerObjectType } from "@tenet-registry/src/Utils.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { Creature, CreatureData } from "@tenet-creatures/src/codegen/tables/Creature.sol";

import { VoxelCoord, ObjectProperties, Action, ElementType } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, WaterCreatureObjectID } from "@tenet-creatures/src/Constants.sol";
import { tryStoppingAction } from "@tenet-world/src/Utils.sol";
import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { CreatureMove } from "@tenet-creatures/src/Types.sol";

contract WaterCreatureObjectSystem is AgentType {
  function registerObject() public {
    address world = _world();
    registerObjectType(
      REGISTRY_ADDRESS,
      WaterCreatureObjectID,
      world,
      IWorld(world).creatures_WaterCreatureObj_enterWorld.selector,
      IWorld(world).creatures_WaterCreatureObj_exitWorld.selector,
      IWorld(world).creatures_WaterCreatureObj_eventHandler.selector,
      IWorld(world).creatures_WaterCreatureObj_neighbourEventHandler.selector,
      "Water Creature",
      ""
    );
  }

  function enterWorld(
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) public override returns (ObjectProperties memory) {
    address worldAddress = _msgSender();
    ObjectProperties memory objectProperties;
    objectProperties.mass = 10;

    Creature.set(
      worldAddress,
      objectEntityId,
      CreatureData({
        elementType: ElementType.Water,
        fightingObjectEntityId: bytes32(0),
        isFainted: false,
        lastFaintedBlock: 0,
        numWins: 0,
        numLosses: 0,
        hasValue: true
      })
    );
    return objectProperties;
  }

  function exitWorld(bytes32 objectEntityId, VoxelCoord memory coord) public override {
    address worldAddress = _msgSender();
    Creature.deleteRecord(worldAddress, objectEntityId);
  }

  function eventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (Action[] memory) {
    return super.eventHandler(centerObjectEntityId, neighbourObjectEntityIds);
  }

  function defaultEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_defaultEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds
      );
  }

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerObjectEntityId
  ) public override returns (bool, Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_neighbourEventHandler(
        worldAddress,
        neighbourEntityId,
        centerObjectEntityId
      );
  }

  function emberEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.Ember
      );
  }

  function flameBurstEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.FlameBurst
      );
  }

  function infernoClashEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.InfernoClash
      );
  }

  function smokeScreenEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.SmokeScreen
      );
  }

  function fireShieldEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.FireShield
      );
  }

  function pyroBarrierEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.PyroBarrier
      );
  }

  function waterGunEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.WaterGun
      );
  }

  function hydroPumpEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.HydroPump
      );
  }

  function tidalCrashEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.TidalCrash
      );
  }

  function bubbleEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.Bubble
      );
  }

  function aquaRingEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.AquaRing
      );
  }

  function mistVeilEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.MistVeil
      );
  }

  function vineWhipEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.VineWhip
      );
  }

  function solarBeamEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.SolarBeam
      );
  }

  function thornBurstEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.ThornBurst
      );
  }

  function leechSeedEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.LeechSeed
      );
  }

  function synthesisEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.Synthesis
      );
  }

  function verdantGuardEventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public returns (Action[] memory) {
    address worldAddress = _msgSender();
    return
      IWorld(_world()).creatures_CreatureSystem_moveEventHandler(
        worldAddress,
        centerObjectEntityId,
        neighbourObjectEntityIds,
        CreatureMove.VerdantGuard
      );
  }
}
