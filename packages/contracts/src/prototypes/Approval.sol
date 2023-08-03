// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { InterfaceVoxel } from "@tenet-contracts/src/Types.sol";

// TODO: do we even need this approve contract? we just need the function schema to be the same
// returns true if the approver Approve the caller to call the callee (which is a function selector)
abstract contract Approval is System {

}
