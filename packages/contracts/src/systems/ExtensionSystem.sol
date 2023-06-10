// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Extension, ExtensionTableId } from "../codegen/Tables.sol";
import { addressToEntityKey } from "../utils.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { Occurrence } from "../codegen/Tables.sol";
import { console } from "forge-std/console.sol";

contract ExtensionSystem is System {

  function registerExtension(bytes4 eventHandler) public {
    address contractAddress = _msgSender();
    require(uint256(SystemRegistry.get(caller)) != 0, "Caller is not a system"); // cannot be called by an EOA
    bytes32 resourceSelector = SystemRegistry.get(caller);
    bytes16 callerNamespace = ResourceSelector.getNamespace(resourceSelector);

    // check if extension is already registered
    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((callerNamespace));
    keyTuple[1] = bytes32((contractAddress));
    require(!hasKey(ExtensionTableId, keyTuple), "Extension already registered");

    // register extension
    Extension.set(callerNamespace, contractAddress, eventHandler);
  }

}