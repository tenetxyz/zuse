// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { MindRegistry, MindRegistryTableId, ObjectTypeRegistryTableId, ObjectTypeRegistry } from "@tenet-registry/src/codegen/Tables.sol";
import { Mind, CreationMetadata, CreationSpawns } from "@tenet-utils/src/Types.sol";

contract MindRegistrySystem is System {
  function registerMind(
    bytes32 objectTypeId,
    address mindAddress,
    bytes4 mindSelector,
    string memory name,
    string memory description
  ) public {
    require(
      hasKey(ObjectTypeRegistryTableId, ObjectTypeRegistry.encodeKeyTuple(objectTypeId)),
      "MindRegistrySystem: Object type ID has not been registered"
    );
    // Set creator
    CreationSpawns[] memory spawns = new CreationSpawns[](0);
    bytes memory creationMetadata = abi.encode(CreationMetadata(tx.origin, name, description, spawns));
    Mind memory mind = Mind({
      creationMetadata: creationMetadata,
      mindAddress: mindAddress,
      mindSelector: mindSelector
    });

    Mind[] memory newMinds;
    if (hasKey(MindRegistryTableId, MindRegistry.encodeKeyTuple(objectTypeId))) {
      bytes memory mindData = MindRegistry.get(objectTypeId);
      Mind[] memory minds = abi.decode(mindData, (Mind[]));

      newMinds = new Mind[](minds.length + 1);
      for (uint256 i = 0; i < minds.length; i++) {
        require(
          minds[i].mindAddress != mind.mindAddress || minds[i].mindSelector != mind.mindSelector,
          "MindRegistrySystem: Mind already registered"
        );
        newMinds[i] = minds[i];
      }
      newMinds[minds.length] = mind;
    } else {
      newMinds = new Mind[](1);
      newMinds[0] = mind;
    }

    MindRegistry.set(objectTypeId, abi.encode(newMinds));
  }
}
