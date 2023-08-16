// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { MindRegistry, MindRegistryTableId, BodyTypeRegistryTableId, BodyTypeRegistry, WorldRegistry, WorldRegistryTableId, WorldRegistryData } from "../codegen/Tables.sol";
import { Mind } from "@tenet-utils/src/Types.sol";

contract MindRegistrySystem is System {
  function registerMind(bytes32 bodyTypeId, Mind memory mind) public {
    registerMindForWorld(bodyTypeId, address(0), mind);
  }

  function registerMindForWorld(bytes32 bodyTypeId, address worldAddress, Mind memory mind) public {
    require(
      hasKey(BodyTypeRegistryTableId, BodyTypeRegistry.encodeKeyTuple(bodyTypeId)),
      "Body type ID has not been registered"
    );
    if (worldAddress != address(0)) {
      require(
        hasKey(WorldRegistryTableId, WorldRegistry.encodeKeyTuple(worldAddress)),
        "World address has not been registered"
      );
    }
    // Set creator
    mind.creator = tx.origin;

    Mind[] memory newMinds;
    if (hasKey(MindRegistryTableId, MindRegistry.encodeKeyTuple(bodyTypeId, worldAddress))) {
      bytes memory mindData = MindRegistry.get(bodyTypeId, worldAddress);
      Mind[] memory minds = abi.decode(mindData, (Mind[]));

      newMinds = new Mind[](minds.length + 1);
      for (uint256 i = 0; i < minds.length; i++) {
        require(minds[i].mindSelector != mind.mindSelector, "Mind already registered");
        newMinds[i] = minds[i];
      }
      newMinds[minds.length] = mind;
    } else {
      newMinds = new Mind[](1);
      newMinds[0] = mind;
    }

    MindRegistry.set(bodyTypeId, worldAddress, abi.encode(newMinds));
  }
}
