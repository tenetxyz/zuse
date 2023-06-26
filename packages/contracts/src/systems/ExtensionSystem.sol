// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { NamespaceOwner } from "@latticexyz/world/src/tables/NamespaceOwner.sol";
import { FunctionSelectors } from "@latticexyz/world/src/modules/core/tables/FunctionSelectors.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelInteractionExtension, VoxelInteractionExtensionTableId } from "../codegen/Tables.sol";
import { addressToEntityKey } from "../utils.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { Occurrence } from "../codegen/Tables.sol";
import { console } from "forge-std/console.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";

contract ExtensionSystem is System {
  function registerExtension(bytes4 eventHandler) public {
    (bytes16 namespace, , ) = FunctionSelectors.get(eventHandler);
    require(NamespaceOwner.get(namespace) == _msgSender(), "Caller is not namespace owner");

    // check if extension is already registered
    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((namespace));
    keyTuple[1] = bytes32((eventHandler));
    require(!hasKey(VoxelInteractionExtensionTableId, keyTuple), "Extension already registered");

    // register extension
    VoxelInteractionExtension.set(namespace, eventHandler, false);
  }
}
