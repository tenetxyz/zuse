// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { BuildEvent } from "@tenet-base-world/src/prototypes/BuildEvent.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

abstract contract BuildSystem is BuildEvent {
  function build(
    bytes32 actingObjectEntityId,
    bytes32 buildObjectTypeId,
    VoxelCoord memory buildCoord,
    bytes32 inventoryId
  ) public virtual returns (bytes32);

  function build(
    bytes32 actingObjectEntityId,
    bytes32 buildObjectTypeId,
    VoxelCoord memory buildCoord
  ) public virtual returns (bytes32) {
    address caller = _msgSender();
    if (caller != _world() && caller != getSimulatorAddress()) {
      revert("BuildSystem: Only the world or simulator can call this function");
    }
    return build(actingObjectEntityId, buildObjectTypeId, buildCoord, bytes32(0));
  }

  function buildTerrain(bytes32 actingObjectEntityId, VoxelCoord memory buildCoord) public virtual returns (bytes32) {
    return build(actingObjectEntityId, IWorld(_world()).getTerrainObjectTypeId(buildCoord), buildCoord);
  }
}
