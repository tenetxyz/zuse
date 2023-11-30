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

    world.world_AirObjectSystem_registerBody();
    world.world_DirtObjectSystem_registerBody();
    world.world_GrassObjectSyste_registerBody();
    world.world_BedrockObjectSys_registerBody();
    world.world_StoneObjectSyste_registerBody();
    world.world_BuilderObjectSys_registerBody();
    world.world_FaucetObjectSyst_registerBody();

    world.world_SpawnTerrainSyst_initSpawnTerrain();

    vm.stopBroadcast();
  }
}
