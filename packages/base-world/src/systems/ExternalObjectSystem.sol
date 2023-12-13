// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { getEnterWorldSelector, getExitWorldSelector } from "@tenet-registry/src/Utils.sol";

// This system is used by objects when they need access to
// the object properties. They can't read it directly from the world
// address, since they dont know the simulator address
// TODO: Figure out a way to handle this where this system is not needed
abstract contract ExternalObjectSystem is System {
  function getSimulatorAddress() internal pure virtual returns (address);

  function getObjectProperties(bytes32 objectEntityId) public view virtual returns (ObjectProperties memory);
}
