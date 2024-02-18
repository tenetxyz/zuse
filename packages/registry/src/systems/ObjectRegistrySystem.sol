// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { ObjectTypeRegistry, ObjectTypeRegistryData, ObjectTypeRegistryTableId } from "@tenet-registry/src/codegen/Tables.sol";

contract ObjectRegistrySystem is System {
  function registerObjectType(
    bytes32 objectTypeId,
    address contractAddress,
    bytes4 enterWorldSelector,
    bytes4 exitWorldSelector,
    bytes4 eventHandlerSelector,
    bytes4 neighbourEventHandlerSelector,
    uint8 stackable,
    uint16 maxUses,
    string memory name
  ) public {
    require(
      !hasKey(ObjectTypeRegistryTableId, ObjectTypeRegistry.encodeKeyTuple(objectTypeId)),
      "Object type ID has already been registered"
    );
    require(bytes(name).length > 0, "Name cannot be empty");

    // TODO: Check that the selectors are valid

    ObjectTypeRegistry.set(
      objectTypeId,
      ObjectTypeRegistryData({
        creator: tx.origin,
        contractAddress: contractAddress,
        enterWorldSelector: enterWorldSelector,
        exitWorldSelector: exitWorldSelector,
        eventHandlerSelector: eventHandlerSelector,
        neighbourEventHandlerSelector: neighbourEventHandlerSelector,
        stackable: stackable,
        maxUses: maxUses,
        name: name
      })
    );
  }
}
