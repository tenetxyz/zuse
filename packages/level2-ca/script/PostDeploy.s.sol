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

    // Register the voxel types
    IWorld(worldAddress).registerVoxelAir();
    IWorld(worldAddress).registerVoxelDirt();
    IWorld(worldAddress).registerVoxelGrass();
    IWorld(worldAddress).registerVoxelBedrock();
    IWorld(worldAddress).registerVoxelWire();
    IWorld(worldAddress).registerVoxelSignalSource();
    IWorld(worldAddress).registerVoxelSignal();

    // Register the voxel interactions
    IWorld(worldAddress).registerInteractionWire();
    IWorld(worldAddress).registerInteractionSignal();

    IWorld(worldAddress).registerCA();

    vm.stopBroadcast();
  }
}