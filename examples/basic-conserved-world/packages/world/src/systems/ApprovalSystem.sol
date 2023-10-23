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
import { VoxelType } from "@tenet-world/src/codegen/tables/VoxelType.sol";
import { WorldConfig } from "@tenet-world/src/codegen/tables/WorldConfig.sol";
import { MineEventData, BuildEventData, MoveEventData, ActivateEventData } from "@tenet-base-world/src/Types.sol";
import { MineWorldEventData, BuildWorldEventData, MoveWorldEventData, ActivateWorldEventData, FluxEventData } from "@tenet-world/src/Types.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { getCallerName } from "@tenet-utils/src/Utils.sol";
import { getEntityAtCoord, getEntityPositionStrict, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { updateVelocityCache } from "@tenet-simulator/src/CallUtils.sol";
import { console } from "forge-std/console.sol";

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
    VoxelCoord memory oldCoord = coord;
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
      oldCoord = moveEventData.oldCoord;
    }

    // Assert that this entity is owned by the caller or is a CA
    bool isEOACaller = hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(agentEntity.scale, agentEntity.entityId)) &&
      OwnedBy.get(agentEntity.scale, agentEntity.entityId) == caller;
    bool isWorldCaller = caller == _world(); // any root system can call this
    bool isSimCaller = caller == SIMULATOR_ADDRESS;
    console.log("approval bro");
    require(isEOACaller || isWorldCaller || isSimCaller, "Agent entity must be owned by caller or be a root system");
    console.log("approval done");

    agentEntityChecks(eventType, caller, voxelTypeId, coord, oldCoord, agentEntity);

    updateVelocityCache(SIMULATOR_ADDRESS, agentEntity);
    bytes32 entityId = getEntityAtCoord(agentEntity.scale, coord);
    if (uint256(entityId) != 0 && entityId != agentEntity.entityId) {
      updateVelocityCache(SIMULATOR_ADDRESS, VoxelEntity({ scale: agentEntity.scale, entityId: entityId }));
    }
  }

  function agentEntityChecks(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelCoord memory oldCoord,
    VoxelEntity memory agentEntity
  ) internal {
    // Assert that this entity has a position
    VoxelCoord memory agentPosition = positionDataToVoxelCoord(getEntityPositionStrict(agentEntity));
    // caller == SIMULATOR_ADDRESS is so a chain of collisions can still be approved
    // in a chain, the agent causing the collision may not be adjacent to the voxel
    require(
      distanceBetween(agentPosition, oldCoord) <= MAX_AGENT_ACTION_RADIUS || caller == SIMULATOR_ADDRESS,
      "Agent must be adjacent to voxel"
    );
    require(distanceBetween(oldCoord, coord) <= MAX_AGENT_ACTION_RADIUS, "Old coord must be adjacent to new coord");
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
  ) internal override {}

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
