// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    IWorld world = IWorld(worldAddress);

    // TODO: Find a better way to auto get these in deployPrettyBlocks.tsx
    console.log("Enter World Selector");
    console.logBytes4(world.pretty_PrettyObjectSyst_enterWorld.selector);
    console.log("Exit World Selector");
    console.logBytes4(world.pretty_PrettyObjectSyst_exitWorld.selector);
    console.log("Event Handler Selector");
    console.logBytes4(world.pretty_PrettyObjectSyst_eventHandler.selector);
    console.log("Neighbour Event Handler Selector");
    console.logBytes4(world.pretty_PrettyObjectSyst_neighbourEventHandler.selector);

    vm.stopBroadcast();
  }
}
