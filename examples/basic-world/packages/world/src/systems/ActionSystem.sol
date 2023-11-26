// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EntityActionData, SimTable, Action } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { ActionSystem as ActionProtoSystem } from "@tenet-base-world/src/systems/ActionSystem.sol";

contract ActionSystem is ActionProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function actionHandler(EntityActionData memory entityActionData) public override returns (bool ranAction) {
    return super.actionHandler(entityActionData);
  }
}
