// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { CARegistry, CARegistryTableId, CARegistryData, WorldRegistry, WorldRegistryTableId, WorldRegistryData } from "../codegen/Tables.sol";

contract WorldRegistrySystem is System {
  // TODO: How do we know this world is using these CA's?
  function registerWorld(string memory name, string memory description, address[] memory caAddresses) public {
    require(bytes(name).length > 0, "Name cannot be empty");
    require(bytes(description).length > 0, "Description cannot be empty");

    for (uint256 i; i < caAddresses.length; i++) {
      require(
        hasKey(CARegistryTableId, CARegistry.encodeKeyTuple(caAddresses[i])),
        "CA address has not been registered"
      );
      // TODO: We could add some additional checks, like require there is only one scale 1 CA
    }

    address worldAddress = _msgSender();
    require(
      !hasKey(WorldRegistryTableId, WorldRegistry.encodeKeyTuple(worldAddress)),
      "World has already been registered"
    );

    WorldRegistry.set(
      worldAddress,
      WorldRegistryData({ name: name, description: description, creator: tx.origin, caAddresses: caAddresses })
    );
  }
}
