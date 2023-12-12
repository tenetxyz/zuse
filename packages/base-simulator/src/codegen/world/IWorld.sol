// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";

import { ISimInitSystem } from "./ISimInitSystem.sol";
import { IWorldActivateEventSystem } from "./IWorldActivateEventSystem.sol";
import { IWorldBuildEventSystem } from "./IWorldBuildEventSystem.sol";
import { IWorldMineEventSystem } from "./IWorldMineEventSystem.sol";
import { IWorldMoveEventSystem } from "./IWorldMoveEventSystem.sol";
import { IWorldObjectEventSystem } from "./IWorldObjectEventSystem.sol";

/**
 * The IWorld interface includes all systems dynamically added to the World
 * during the deploy process.
 */
interface IWorld is
  IBaseWorld,
  ISimInitSystem,
  IWorldActivateEventSystem,
  IWorldBuildEventSystem,
  IWorldMineEventSystem,
  IWorldMoveEventSystem,
  IWorldObjectEventSystem
{

}
