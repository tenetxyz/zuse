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
    IWorld(worldAddress).extension1_WireVoxelSystem_registerBody();
    IWorld(worldAddress).extension1_SignalSourceVoxe_registerBody();
    IWorld(worldAddress).extension1_SignalVoxelSyste_registerBody();
    IWorld(worldAddress).extension1_InvertedSignalVo_registerBody();
    IWorld(worldAddress).extension1_SandVoxelSystem_registerBody();
    IWorld(worldAddress).extension1_FlowerVoxelSyste_registerBody();
    IWorld(worldAddress).extension1_LogVoxelSystem_registerBody();
    IWorld(worldAddress).extension1_LavaVoxelSystem_registerBody();
    IWorld(worldAddress).extension1_IceVoxelSystem_registerBody();
    IWorld(worldAddress).extension1_ThermoGenVoxelSy_registerBody();
    IWorld(worldAddress).extension1_PowerWireVoxelSy_registerBody();
    IWorld(worldAddress).extension1_StorageVoxelSyst_registerBody();
    IWorld(worldAddress).extension1_LightBulbVoxelSy_registerBody();
    IWorld(worldAddress).extension1_PowerSignalVoxel_registerBody();

    vm.stopBroadcast();
  }
}
