// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CAMind, CAMindTableId } from "@tenet-base-ca/src/codegen/tables/CAMind.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAVoxelType, CAVoxelTypeTableId } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { getEntityAtCoord, entityArrayToCAEntityArray, entityToCAEntity, caEntityArrayToEntityArray } from "@tenet-base-ca/src/Utils.sol";

abstract contract CAExternal is System {
  function getMindSelector(bytes32 entity) public view virtual returns (bytes4) {
    address callerAddress = _msgSender();
    bytes32 caEntity = entityToCAEntity(callerAddress, entity);
    require(hasKey(CAMindTableId, CAMind.encodeKeyTuple(caEntity)), "Mind does not exist");
    return CAMind.getMindSelector(caEntity);
  }

  function setMindSelector(bytes32 entity, bytes4 mindSelector) public virtual {
    address callerAddress = _msgSender();
    bytes32 caEntity = entityToCAEntity(callerAddress, entity);
    require(hasKey(CAMindTableId, CAMind.encodeKeyTuple(caEntity)), "Mind does not exist");
    CAMind.setMindSelector(caEntity, mindSelector);
  }
}
