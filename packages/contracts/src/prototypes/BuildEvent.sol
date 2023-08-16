// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { Event } from "./Event.sol";
import { VoxelCoord, BuildEventData } from "../Types.sol";
import { BodyTypeRegistry, BodyTypeRegistryData } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { WorldConfig, WorldConfigTableId, OwnedBy, Position, PositionTableId, BodyType, BodyTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { CABodyType, CABodyTypeData } from "@tenet-base-ca/src/codegen/tables/CABodyType.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { calculateChildCoords, getEntityAtCoord, calculateParentCoord } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { AirVoxelVariantID } from "@tenet-base-ca/src/Constants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { bodySpawned } from "@tenet-registry/src/Utils.sol";

abstract contract BuildEvent is Event {
  // Called by users
  function build(
    uint32 scale,
    bytes32 entity,
    VoxelCoord memory coord,
    bytes4 mindSelector
  ) public virtual returns (uint32, bytes32);

  // Called by CA
  function buildBodyType(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool buildChildren,
    bool buildParent,
    bytes memory eventData
  ) public virtual returns (uint32, bytes32) {
    (uint32 scale, bytes32 eventBodyEntity) = super.runEventHandler(
      bodyTypeId,
      coord,
      buildChildren,
      buildParent,
      eventData
    );
    bodySpawned(REGISTRY_ADDRESS, bodyTypeId);
    return (scale, eventBodyEntity);
  }

  function preEvent(bytes32 bodyTypeId, VoxelCoord memory coord, bytes memory eventData) internal override {
    IWorld(_world()).approveBuild(tx.origin, bodyTypeId, coord);
  }

  function postEvent(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {}

  function runEventHandlerForParent(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {
    buildParentBody(scale, eventBodyEntity, coord, eventData);
  }

  function runEventHandlerForIndividualChildren(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes32 childBodyTypeId,
    VoxelCoord memory childCoord,
    bytes memory eventData
  ) internal override {
    if (childBodyTypeId != 0) {
      runEventHandler(
        childBodyTypeId,
        childCoord,
        true,
        false,
        abi.encode(BuildEventData({ mindSelector: bytes4(0) })) // TODO: which mind to use for the children?
      );
    }
  }

  function preRunCA(
    address caAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {
    BuildEventData memory buildEventData = abi.decode(eventData, (BuildEventData));
    // Enter World
    IWorld(_world()).enterCA(caAddress, scale, bodyTypeId, buildEventData.mindSelector, coord, eventBodyEntity);
  }

  function postRunCA(
    address caAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {}

  function runCA(address caAddress, uint32 scale, bytes32 eventBodyEntity, bytes memory eventData) internal override {
    IWorld(_world()).runCA(caAddress, scale, eventBodyEntity, bytes4(0));
  }

  function hasSameBodyTypeSchema(
    uint32 scale,
    bytes32[] memory referenceBodyTypeIds,
    bytes32[] memory existingBodyTypeIds,
    VoxelCoord[] memory eightBlockBodyCoords
  ) internal view virtual returns (bool) {
    if (referenceBodyTypeIds.length != existingBodyTypeIds.length) {
      return false;
    }
    for (uint256 i = 0; i < referenceBodyTypeIds.length; i++) {
      if (referenceBodyTypeIds[i] != 0) {
        if (referenceBodyTypeIds[i] != existingBodyTypeIds[i]) {
          return false;
        }
      } else {
        bytes32 siblingEntity = getEntityAtCoord(scale, eightBlockBodyCoords[i]);
        if (siblingEntity != 0 && BodyType.getBodyVariantId(scale, siblingEntity) != AirVoxelVariantID) {
          return false;
        }
      }
    }
    return true;
  }

  function buildParentBody(
    uint32 buildScale,
    bytes32 buildBodyEntity,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual {
    // Calculate childBodyTypes
    VoxelCoord memory parentVoxelCoord = calculateParentCoord(2, coord);
    VoxelCoord[] memory eightBlockBodyCoords = calculateChildCoords(2, parentVoxelCoord);
    bytes32[] memory existingChildBodyTypes = new bytes32[](8);
    uint32 existingCount = 0;
    for (uint8 i = 0; i < 8; i++) {
      bytes32 siblingEntity = getEntityAtCoord(buildScale, eightBlockBodyCoords[i]);
      if (siblingEntity != 0) {
        existingChildBodyTypes[i] = BodyType.getBodyTypeId(buildScale, siblingEntity);
        existingCount += 1;
      }
    }

    // Check if parent is there, and build if there
    bytes32[][] memory worldBodyTypeKeys = getKeysInTable(WorldConfigTableId);
    for (uint256 i = 0; i < worldBodyTypeKeys.length; i++) {
      bytes32 worldBodyTypeId = worldBodyTypeKeys[i][0];
      BodyTypeRegistryData memory bodyTypeData = BodyTypeRegistry.get(IStore(REGISTRY_ADDRESS), worldBodyTypeId);
      if (bodyTypeData.scale == buildScale + 1) {
        bool hasSameSchema = hasSameBodyTypeSchema(
          buildScale,
          bodyTypeData.schemaBodyTypeIds,
          existingChildBodyTypes,
          eightBlockBodyCoords
        );

        if (hasSameSchema) {
          (uint32 parentScale, bytes32 parentBodyEntity) = super.runEventHandlerHelper(
            worldBodyTypeId,
            parentVoxelCoord,
            false,
            abi.encode(BuildEventData({ mindSelector: bytes4(0) })) // TODO: which mind to use for the parent?
          );
          buildParentBody(parentScale, parentBodyEntity, parentVoxelCoord, eventData);
          break;
        }
      }
    }
  }
}
