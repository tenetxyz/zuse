// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Call world init function
    IWorld world = IWorld(worldAddress);
    world.tenet_AirVoxelSystem_registerVoxel();
    world.tenet_DirtVoxelSystem_registerVoxel();
    world.tenet_GrassVoxelSystem_registerVoxel();
    world.tenet_BedrockVoxelSyst_registerVoxel();
    world.tenet_RoadVoxelSystem_registerVoxel();

    // Note: These have to be here instead of InitSystem as they have be called from the deployer account
    // otherwise the msgSender is not the namespace owner

    vm.stopBroadcast();
  }
}
