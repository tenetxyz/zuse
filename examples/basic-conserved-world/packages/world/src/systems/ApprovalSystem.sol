// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { EventApprovalsSystem } from "@tenet-base-world/src/prototypes/EventApprovalsSystem.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { EventType } from "@tenet-base-world/src/Types.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-world/src/codegen/tables/OwnedBy.sol";
import { BodyPhysics, BodyPhysicsData } from "@tenet-world/src/codegen/tables/BodyPhysics.sol";
import { WorldConfig } from "@tenet-world/src/codegen/tables/WorldConfig.sol";
import { MineEventData, BuildEventData, MoveEventData, ActivateEventData } from "@tenet-base-world/src/Types.sol";
import { MineWorldEventData, BuildWorldEventData, MoveWorldEventData, ActivateWorldEventData } from "@tenet-world/src/Types.sol";
import { distanceBetween } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { getCallerName } from "@tenet-utils/src/Utils.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";

uint256 constant MAX_AGENT_ACTION_RADIUS = 1;

contract ApprovalSystem is EventApprovalsSystem {
  function preApproval(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal override {
    VoxelEntity memory agentEntity;
    if (eventType == EventType.Mine) {
      MineEventData memory mineEventData = abi.decode(eventData, (MineEventData));
      MineWorldEventData memory mineWorldEventData = abi.decode(mineEventData.worldData, (MineWorldEventData));
      agentEntity = mineWorldEventData.agentEntity;
    } else if (eventType == EventType.Build) {
      BuildEventData memory buildEventData = abi.decode(eventData, (BuildEventData));
      BuildWorldEventData memory buildWorldEventData = abi.decode(buildEventData.worldData, (BuildWorldEventData));
      agentEntity = buildWorldEventData.agentEntity;
    } else if (eventType == EventType.Activate) {
      ActivateEventData memory activateEventData = abi.decode(eventData, (ActivateEventData));
      ActivateWorldEventData memory activateWorldEventData = abi.decode(
        activateEventData.worldData,
        (ActivateWorldEventData)
      );
      agentEntity = activateWorldEventData.agentEntity;
    } else if (eventType == EventType.Move) {
      MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
      MoveWorldEventData memory moveWorldEventData = abi.decode(moveEventData.worldData, (MoveWorldEventData));
      agentEntity = moveWorldEventData.agentEntity;
    }

    // Assert that this entity is owned by the caller or is a CA
    bool isEOACaller = hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(agentEntity.scale, agentEntity.entityId)) &&
      OwnedBy.get(agentEntity.scale, agentEntity.entityId) == caller;
    bool isAllowedWorldSystem = false;
    if (!isEOACaller) {
      bytes16 systemName = getCallerName(caller);
      if (systemName == bytes16("CAEventsSystem")) {
        isAllowedWorldSystem = true;
      }
    }
    require(isEOACaller || isAllowedWorldSystem, "Agent entity must be owned by caller");

    agentEntityChecks(eventType, caller, voxelTypeId, coord, agentEntity);
  }

  function agentEntityChecks(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory agentEntity
  ) internal {
    // Assert that this entity has a position
    VoxelCoord memory agentPosition = positionDataToVoxelCoord(getEntityPositionStrict(agentEntity));
    require(distanceBetween(agentPosition, coord) == MAX_AGENT_ACTION_RADIUS, "Agent must be adjacent to voxel");
  }

  function postApproval(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal override {}

  function approveEvent(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal override {
    // TODO: This is duplicated from Event.sol, should consolidate it
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(REGISTRY_ADDRESS), voxelTypeId);
    address caAddress = WorldConfig.get(voxelTypeId);
    uint32 scale = voxelTypeData.scale;
    bytes32 entityId = getEntityAtCoord(scale, coord);
    if (eventType == EventType.Build) {
      if (uint256(entityId) != 0) {
        require(BodyPhysics.getMass(scale, entityId) == 0, "Cannot build on top of an entity with mass");
      } else {
        (, BodyPhysicsData memory terrainPhysicsData) = IWorld(_world()).getTerrainBodyPhysicsData(caAddress, coord);
        require(terrainPhysicsData.mass == 0, "Cannot build on top of terrain with mass");
      }
    } else if (eventType == EventType.Build) {
      if (uint256(entityId) != 0) {
        require(BodyPhysics.getMass(scale, entityId) > 0, "Cannot mine an entity with no mass");
      } else {
        (, BodyPhysicsData memory terrainPhysicsData) = IWorld(_world()).getTerrainBodyPhysicsData(caAddress, coord);
        require(terrainPhysicsData.mass > 0, "Cannot mine terrain with no mass");
      }
    } else if (eventType == EventType.Move) {
      if (uint256(entityId) != 0) {
        require(BodyPhysics.getMass(scale, entityId) == 0, "Cannot move on top of an entity with mass");
      } else {
        (, BodyPhysicsData memory terrainPhysicsData) = IWorld(_world()).getTerrainBodyPhysicsData(caAddress, coord);
        require(terrainPhysicsData.mass == 0, "Cannot move on top of terrain with mass");
      }
    }
  }

  function approveMine(
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public override {
    super.approveMine(caller, voxelTypeId, coord, eventData);
  }

  function approveBuild(
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public override {
    super.approveBuild(caller, voxelTypeId, coord, eventData);
  }

  function approveActivate(
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public override {
    super.approveActivate(caller, voxelTypeId, coord, eventData);
  }

  function approveMove(
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public override {
    super.approveMove(caller, voxelTypeId, coord, eventData);
  }
}
