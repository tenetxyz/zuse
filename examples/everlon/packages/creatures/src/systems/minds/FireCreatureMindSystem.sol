// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-creatures/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MindType } from "@tenet-base-world/src/prototypes/MindType.sol";
import { IMindRegistrySystem } from "@tenet-registry/src/codegen/world/IMindRegistrySystem.sol";

import { REGISTRY_ADDRESS, FireCreatureObjectID } from "@tenet-creatures/src/Constants.sol";

contract FireCreatureMindSystem is MindType {
  function registerMind() public {
    IMindRegistrySystem(REGISTRY_ADDRESS).registerMind(
      FireCreatureObjectID,
      _world(),
      IWorld(_world()).creatures_FireCreatureMind_eventHandlerSelector.selector,
      "Fire Creature Test Mind",
      ""
    );
  }

  function eventHandlerSelector(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (address, bytes4) {
    address worldAddress = _world();
    bytes4 moveSelector = IWorld(worldAddress).creatures_FireCreatureObje_flameBurstEventHandler.selector;
    return (worldAddress, moveSelector);
  }
}
