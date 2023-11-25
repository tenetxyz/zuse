// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";

import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";

abstract contract EventApprovalsSystem is System {
  function getSimulatorAddress() internal pure virtual returns (address);

  function preApproval(
    EventType eventType,
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual {
    // Assert that this entity is owned by the caller or is a CA
    bool isEOACaller = hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(actingObjectEntityId)) &&
      OwnedBy.get(actingObjectEntityId) == caller;
    bool isWorldCaller = caller == _world(); // any root system can call this
    bool isSimCaller = caller == getSimulatorAddress();
    require(
      isEOACaller || isWorldCaller || isSimCaller,
      "Agent entity must be owned by caller or be an approved system"
    );
  }

  function approveEvent(
    EventType eventType,
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual;

  function postApproval(
    EventType eventType,
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual;

  function approveMine(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual {
    preApproval(EventType.Mine, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    approveEvent(EventType.Mine, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    postApproval(EventType.Mine, caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function approveBuild(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual {
    preApproval(EventType.Build, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    approveEvent(EventType.Build, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    postApproval(EventType.Build, caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function approveActivate(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual {
    preApproval(EventType.Activate, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    approveEvent(EventType.Activate, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    postApproval(EventType.Activate, caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function approveMove(
    address caller,
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual {
    preApproval(EventType.Move, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    approveEvent(EventType.Move, caller, actingObjectEntityId, objectTypeId, coord, eventData);
    postApproval(EventType.Move, caller, actingObjectEntityId, objectTypeId, coord, eventData);
  }
}
