// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { NamespaceOwner } from "@latticexyz/world/src/tables/NamespaceOwner.sol";
import { FunctionSelectors } from "@latticexyz/world/src/modules/core/tables/FunctionSelectors.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelInteractionExtension, VoxelInteractionExtensionTableId } from "@tenet-contracts/src/codegen/Tables.sol";
import { addressToEntityKey } from "../Utils.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { Occurrence } from "@tenet-contracts/src/codegen/Tables.sol";
import { console } from "forge-std/console.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { getCallerNamespace } from "../SharedUtils.sol";

contract ExtensionSystem is System {
  function registerExtension(bytes4 eventHandler, string memory extensionName) public {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    // check if extension is already registered
    // TODO: should we also store the name of the extension in the table?
    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((callerNamespace));
    keyTuple[1] = bytes32((eventHandler));
    require(
      !hasKey(VoxelInteractionExtensionTableId, keyTuple),
      string(abi.encodePacked(extensionName, " already registered"))
    );

    // register extension
    VoxelInteractionExtension.set(callerNamespace, eventHandler, false);
  }
}
