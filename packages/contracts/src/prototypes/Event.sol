// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { EventType } from "@tenet-contracts/src/Types.sol";
import { VoxelCoord, BodyEntity } from "@tenet-utils/src/Types.sol";
import { WorldConfig, OwnedBy, Position, PositionTableId, BodyType, BodyTypeData, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-contracts/src/Utils.sol";
import { CABodyType, CABodyTypeData } from "@tenet-base-ca/src/codegen/tables/CABodyType.sol";
import { BodyTypeRegistry, BodyTypeRegistryData } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";

abstract contract Event is System {
  function preEvent(bytes32 bodyTypeId, VoxelCoord memory coord, bytes memory eventData) internal virtual;

  function postEvent(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal virtual;

  function callEventHandler(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal virtual returns (uint32, bytes32);

  function runEvent(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (uint32, bytes32) {
    preEvent(bodyTypeId, coord, eventData);

    (uint32 scale, bytes32 eventBodyEntity) = callEventHandler(bodyTypeId, coord, true, true, eventData);

    postEvent(bodyTypeId, coord, scale, eventBodyEntity, eventData);

    return (scale, eventBodyEntity);
  }

  function preRunCA(
    address caAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal virtual;

  function postRunCA(
    address caAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal virtual;

  function runCA(address caAddress, uint32 scale, bytes32 eventBodyEntity, bytes memory eventData) internal virtual;

  function runEventHandlerForParent(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal virtual;

  function runEventHandlerForChildren(
    bytes32 bodyTypeId,
    BodyTypeRegistryData memory bodyTypeData,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal virtual {
    // Read the ChildTypes in this CA address
    bytes32[] memory childBodyTypeIds = bodyTypeData.childBodyTypeIds;
    // TODO: Make this general by using cube root
    require(childBodyTypeIds.length == 8, "Invalid length of child body type ids");
    // TODO: move this to a library
    VoxelCoord[] memory eightBlockBodyCoords = calculateChildCoords(2, coord);
    for (uint8 i = 0; i < 8; i++) {
      runEventHandlerForIndividualChildren(
        bodyTypeId,
        coord,
        scale,
        eventBodyEntity,
        childBodyTypeIds[i],
        eightBlockBodyCoords[i],
        eventData
      );
    }
  }

  function runEventHandlerForIndividualChildren(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes32 childBodyTypeId,
    VoxelCoord memory childCoord,
    bytes memory eventData
  ) internal virtual;

  // Called by CA
  function runEventHandler(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal virtual returns (uint32, bytes32) {
    require(
      _msgSender() == _world() || IWorld(_world()).isCAAllowed(_msgSender()),
      "Not allowed to run event handler. Must be world or CA"
    );
    (uint32 scale, bytes32 eventBodyEntity) = runEventHandlerHelper(bodyTypeId, coord, runEventOnChildren, eventData);

    if (runEventOnParent) {
      runEventHandlerForParent(bodyTypeId, coord, scale, eventBodyEntity, eventData);
    }

    return (scale, eventBodyEntity);
  }

  function runEventHandlerHelper(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bytes memory eventData
  ) internal virtual returns (uint32, bytes32) {
    require(IWorld(_world()).isBodyTypeAllowed(bodyTypeId), "Voxel type not allowed in this world");
    BodyTypeRegistryData memory bodyTypeData = BodyTypeRegistry.get(IStore(REGISTRY_ADDRESS), bodyTypeId);
    address caAddress = WorldConfig.get(bodyTypeId);

    uint32 scale = bodyTypeData.scale;

    bytes32 eventBodyEntity = getEntityAtCoord(scale, coord);
    if (uint256(eventBodyEntity) == 0) {
      eventBodyEntity = getUniqueEntity();
      Position.set(scale, eventBodyEntity, coord.x, coord.y, coord.z);
    }

    if (runEventOnChildren && scale > 1) {
      runEventHandlerForChildren(bodyTypeId, bodyTypeData, coord, scale, eventBodyEntity, eventData);
    }

    preRunCA(caAddress, bodyTypeId, coord, scale, eventBodyEntity, eventData);

    // Set initial voxel type
    CABodyTypeData memory entityCABodyType = CABodyType.get(IStore(caAddress), _world(), eventBodyEntity);
    BodyType.set(scale, eventBodyEntity, entityCABodyType.bodyTypeId, entityCABodyType.bodyVariantId);

    runCA(caAddress, scale, eventBodyEntity, eventData);

    postRunCA(caAddress, bodyTypeId, coord, scale, eventBodyEntity, eventData);

    return (scale, eventBodyEntity);
  }
}
