// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    IWorld world = IWorld(worldAddress);

    world.world_AirObjectSystem_registerObject();
    world.world_DirtObjectSystem_registerObject();
    world.world_GrassObjectSyste_registerObject();
    world.world_BedrockObjectSys_registerObject();
    world.world_BuilderObjectSys_registerObject();

    world.spawnInitialAgents();

    vm.stopBroadcast();
  }
}
