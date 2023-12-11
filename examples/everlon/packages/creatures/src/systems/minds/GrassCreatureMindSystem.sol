// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-creatures/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MindType } from "@tenet-base-world/src/prototypes/MindType.sol";

import { REGISTRY_ADDRESS, GrassCreatureObjectID } from "@tenet-creatures/src/Constants.sol";
import { registerMindIntoRegistry } from "@tenet-registry/src/Utils.sol";

contract GrassCreatureMindSystem is MindType {
  function registerMind() public {
    registerMindIntoRegistry(
      REGISTRY_ADDRESS,
      GrassCreatureObjectID,
      _world(),
      IWorld(_world()).creatures_GrassCreatureMin_eventHandlerSelector.selector,
      "Grass Creature Test Mind",
      ""
    );
  }

  function eventHandlerSelector(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public override returns (address, bytes4) {
    address worldAddress = _world();
    bytes4 moveSelector = IWorld(worldAddress).creatures_GrassCreatureObj_synthesisEventHandler.selector;
    return (worldAddress, moveSelector);
  }
}
