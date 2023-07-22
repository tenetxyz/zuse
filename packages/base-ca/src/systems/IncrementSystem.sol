// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Counter } from "../codegen/Tables.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";

contract IncrementSystem is System {
  function increment() public returns (uint32) {
    // I want to read Counter from a different world
    address world = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    uint32 counter = Counter.get(IStore(world));
    uint32 newValue = counter + 1;
    Counter.set(newValue);
    return newValue;
  }
}
