// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { InterfaceVoxel } from "@tenet-contracts/src/Types.sol";

// returns true if the approver Approve the caller to call the callee (which is a function selector)
abstract contract Approval is System {
  function approve(address caller, bytes4 callee) public virtual returns (bool);
}
