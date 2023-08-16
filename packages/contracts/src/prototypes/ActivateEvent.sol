// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { Event } from "./Event.sol";
import { WorldConfig, Position, PositionTableId, BodyType } from "@tenet-contracts/src/codegen/Tables.sol";
import { BodyTypeRegistry, BodyTypeRegistryData } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord, ActivateEventData } from "../Types.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "../Utils.sol";

abstract contract ActivateEvent is Event {
  // Called by users
  function activate(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bytes4 interactionSelector
  ) public virtual returns (uint32, bytes32) {
    BodyTypeRegistryData memory bodyTypeData = BodyTypeRegistry.get(IStore(REGISTRY_ADDRESS), bodyTypeId);
    uint32 scale = bodyTypeData.scale;
    bytes32 eventBodyEntity = getEntityAtCoord(scale, coord);
    require(eventBodyEntity != 0, "ActivateEvent: no body entity at coord");
    return runEvent(bodyTypeId, coord, abi.encode(ActivateEventData({ interactionSelector: interactionSelector })));
  }

  // Called by CA
  function activateBodyType(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool activateChildren,
    bool activateParent,
    bytes memory eventData
  ) public virtual returns (uint32, bytes32);

  function preEvent(bytes32 bodyTypeId, VoxelCoord memory coord, bytes memory eventData) internal override {
    IWorld(_world()).approveActivate(tx.origin, bodyTypeId, coord);
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
  ) internal override {}

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
        abi.encode(ActivateEventData({ interactionSelector: bytes4(0) }))
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
  ) internal override {}

  function postRunCA(
    address caAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {
    IWorld(_world()).activateCA(caAddress, scale, eventBodyEntity);
  }

  function runCA(address caAddress, uint32 scale, bytes32 eventBodyEntity, bytes memory eventData) internal override {
    ActivateEventData memory activateEventData = abi.decode(eventData, (ActivateEventData));
    IWorld(_world()).runCA(caAddress, scale, eventBodyEntity, activateEventData.interactionSelector);
  }
}
