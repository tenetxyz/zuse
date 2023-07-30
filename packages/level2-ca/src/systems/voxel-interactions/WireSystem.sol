// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@level2-ca/src/codegen/world/IWorld.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { CAVoxelType, CAVoxelTypeData } from "@level2-ca/src/codegen/Tables.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { AirVoxelID, ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";

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

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity) {
    bytes32 bottomLeft = childEntityIds[0];
    bytes32 bottomRight = childEntityIds[1];
    bytes32 topLeft = childEntityIds[4];
    bytes32 topRight = childEntityIds[5];

    bytes32 bottomLeftType = AirVoxelID;
    if (bottomLeft != 0) {
      bytes memory returnData = safeCall(
        callerAddress,
        abi.encodeWithSignature("getVoxelTypeId(uint32,bytes32)", 1, bottomLeft),
        "getVoxelTypeId"
      );
      bottomLeftType = abi.decode(returnData, (bytes32));
    }
    bytes32 bottomRightType = AirVoxelID;
    if (bottomRight != 0) {
      bytes memory returnData = safeCall(
        callerAddress,
        abi.encodeWithSignature("getVoxelTypeId(uint32,bytes32)", 1, bottomRight),
        "getVoxelTypeId"
      );
      bottomRightType = abi.decode(returnData, (bytes32));
    }
    bytes32 topLeftType = AirVoxelID;
    if (topLeft != 0) {
      bytes memory returnData = safeCall(
        callerAddress,
        abi.encodeWithSignature("getVoxelTypeId(uint32,bytes32)", 1, topLeft),
        "getVoxelTypeId"
      );
      topLeftType = abi.decode(returnData, (bytes32));
    }
    bytes32 topRightType = AirVoxelID;
    if (topRight != 0) {
      bytes memory returnData = safeCall(
        callerAddress,
        abi.encodeWithSignature("getVoxelTypeId(uint32,bytes32)", 1, topRight),
        "getVoxelTypeId"
      );
      topRightType = abi.decode(returnData, (bytes32));
    }

    if (topLeftType == ElectronVoxelID && bottomRightType == ElectronVoxelID) {
      if (entityTypeData.voxelVariantId != SignalOffVoxelVariantID) {
        CAVoxelType.set(callerAddress, interactEntity, SignalVoxelID, SignalOffVoxelVariantID);
        changedEntity = true;
      }
    } else if (bottomLeftType == ElectronVoxelID && topRightType == ElectronVoxelID) {
      if (entityTypeData.voxelVariantId != SignalOnVoxelVariantID) {
        CAVoxelType.set(callerAddress, interactEntity, SignalVoxelID, SignalOnVoxelVariantID);
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
