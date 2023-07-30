// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { CAVoxelInteractionConfig, CAVoxelType, CAVoxelTypeData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { AirVoxelID, ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { WireVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { WireOnVoxelVariantID, WireOffVoxelVariantID } from "@tenet-level2-ca/src/systems/voxels/WireVOxelSystem.sol";

contract WireSystem is VoxelInteraction {
  function registerInteractionWire() public {
    address world = _world();
    CAVoxelInteractionConfig.push(IWorld(world).eventHandlerWire.selector);
  }

  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity) {
    return false;
  }

  function getVoxelTypeFromCaller(address callerAddress, uint32 scale, bytes32 entity) internal returns (bytes32) {
    if (entity != 0) {
      bytes memory returnData = safeCall(
        callerAddress,
        abi.encodeWithSignature("getVoxelTypeId(uint32,bytes32)", scale, entity),
        "getVoxelTypeId"
      );
      return abi.decode(returnData, (bytes32));
    }
    return AirVoxelID;
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity) {
    CAVoxelTypeData memory entityTypeData = CAVoxelType.get(callerAddress, interactEntity);

    bytes32 bottomLeftType = getVoxelTypeFromCaller(callerAddress, 1, childEntityIds[0]);
    bytes32 bottomRightType = getVoxelTypeFromCaller(callerAddress, 1, childEntityIds[1]);
    bytes32 topLeftType = getVoxelTypeFromCaller(callerAddress, 1, childEntityIds[4]);
    bytes32 topRightType = getVoxelTypeFromCaller(callerAddress, 1, childEntityIds[5]);

    if (topLeftType == ElectronVoxelID && bottomRightType == ElectronVoxelID) {
      if (entityTypeData.voxelVariantId != WireOffVoxelVariantID) {
        CAVoxelType.set(callerAddress, interactEntity, WireVoxelID, WireOffVoxelVariantID);
        changedEntity = true;
      }
    } else if (bottomLeftType == ElectronVoxelID && topRightType == ElectronVoxelID) {
      if (entityTypeData.voxelVariantId != WireOnVoxelVariantID) {
        CAVoxelType.set(callerAddress, interactEntity, WireVoxelID, WireOnVoxelVariantID);
        changedEntity = true;
      }
    }
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    bytes32 entityType = CAVoxelType.getVoxelTypeId(callerAddress, entityId);
    return entityType == WireVoxelID;
  }

  function eventHandlerWire(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
