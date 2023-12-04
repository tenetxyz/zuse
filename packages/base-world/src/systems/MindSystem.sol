// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { Mind, MindTableId } from "@tenet-base-world/src/codegen/tables/Mind.sol";

abstract contract MindSystem is System {
  function setMindSelector(bytes32 objectEntityId, address mindAddress, bytes4 mindSelector) public {
    require(hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(objectEntityId)), "MindSystem: entity has no owner");
    require(OwnedBy.get(objectEntityId) == _msgSender(), "MindSystem: caller does not own entity");
    Mind.set(objectEntityId, mindAddress, mindSelector);
  }
}
