// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { ExternalObjectSystem as ExternalObjectProtoSystem } from "@tenet-base-world/src/systems/ExternalObjectSystem.sol";

import { SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";

contract ExternalObjectSystem is ExternalObjectProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function getObjectProperties(bytes32 objectEntityId) public view override returns (ObjectProperties memory) {
    IStore store = IStore(getSimulatorAddress());
    address worldAddress = _world();
    ObjectProperties memory objectProperties;
    objectProperties.mass = Mass.get(store, worldAddress, objectEntityId);
    objectProperties.energy = Energy.get(store, worldAddress, objectEntityId);
    return objectProperties;
  }
}
